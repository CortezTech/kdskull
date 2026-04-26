import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dish.dart';

class TableSessionState {
  const TableSessionState({
    required this.table,
    required this.openOrders,
    required this.doneOrders,
  });

  final String table;
  final int openOrders;
  final int doneOrders;

  bool get isOpen => openOrders + doneOrders > 0;
  bool get canClose => isOpen && openOrders == 0;
}

class TableReadyProgress {
  const TableReadyProgress({
    required this.table,
    required this.readyQty,
    required this.totalQty,
  });

  final String table;
  final int readyQty;
  final int totalQty;

  bool get hasItems => totalQty > 0;
  bool get allReady => hasItems && readyQty >= totalQty;
}

class OrdersV2Repository {
  OrdersV2Repository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  Stream<Map<String, TableReadyProgress>> watchReadyProgressByTable() {
    return _orders
        .where('status', whereIn: const ['open', 'done'])
        .snapshots()
        .asyncMap((ordersSnap) async {
          final acc = <String, ({int ready, int total})>{};

          for (final orderDoc in ordersSnap.docs) {
            final orderData = orderDoc.data();
            final table = (orderData['table'] as String?)?.trim() ?? '';
            if (table.isEmpty) continue;

            final itemsSnap = await orderDoc.reference.collection('items').get();
            var ready = 0;
            var total = 0;

            for (final itemDoc in itemsSnap.docs) {
              final itemData = itemDoc.data();
              final status = (itemData['status'] as String?) ?? '';
              if (status == 'served') continue;

              final qty = (itemData['qty'] as int?) ?? 1;
              final normalizedQty = qty <= 0 ? 1 : qty;
              total += normalizedQty;
              if (status == 'ready') ready += normalizedQty;
            }

            final current = acc[table] ?? (ready: 0, total: 0);
            acc[table] = (
              ready: current.ready + ready,
              total: current.total + total,
            );
          }

          final progress = <String, TableReadyProgress>{};
          acc.forEach((table, value) {
            progress[table] = TableReadyProgress(
              table: table,
              readyQty: value.ready,
              totalQty: value.total,
            );
          });

          return progress;
        });
  }

  Stream<Map<String, TableSessionState>> watchTableSessions() {
    return _orders
        .where('status', whereIn: const ['open', 'done'])
        .snapshots()
        .map((snap) {
          final counters = <String, ({int open, int done})>{};

          for (final doc in snap.docs) {
            final data = doc.data();
            final table = (data['table'] as String?)?.trim() ?? '';
            if (table.isEmpty) continue;

            final status = (data['status'] as String?) ?? '';
            final current = counters[table] ?? (open: 0, done: 0);
            if (status == 'open') {
              counters[table] = (open: current.open + 1, done: current.done);
            } else if (status == 'done') {
              counters[table] = (open: current.open, done: current.done + 1);
            }
          }

          final sessions = <String, TableSessionState>{};
          counters.forEach((table, value) {
            sessions[table] = TableSessionState(
              table: table,
              openOrders: value.open,
              doneOrders: value.done,
            );
          });

          return sessions;
        });
  }

  Future<String> createOrderWithItems({
    required String table,
    required List<({Dish dish, int qty, String notes})> lines,
  }) async {
    if (lines.isEmpty) {
      throw StateError('No se permite enviar un pedido vacío');
    }

    final orderRef = await _orders.add({
      'table': table,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'remainingItems': lines.length,
    });

    final batch = _db.batch();
    final itemsCol = orderRef.collection('items');

    for (final l in lines) {
      final dish = l.dish;
      final itemRef = itemsCol.doc();
      batch.set(itemRef, {
        'orderId': orderRef.id,
        'table': table,
        'dishId': dish.id,
        'dishName': dish.name,
        'stationId': dish.stationId,
        'stdPrepTimeSec': dish.stdPrepTimeSec,
        'status': 'todo',
        'qty': l.qty,
        'notes': l.notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return orderRef.id;
  }

  Future<bool> closeTableIfReady(String table) async {
    final normalizedTable = table.trim();
    if (normalizedTable.isEmpty) return false;

    final query = await _orders.where('table', isEqualTo: normalizedTable).get();
    final allTableOrders = query.docs;
    if (allTableOrders.isEmpty) return false;

    final sessionDocs = allTableOrders.where((doc) {
      final status = (doc.data()['status'] as String?) ?? '';
      return status == 'open' || status == 'done';
    }).toList();

    final hasPending = sessionDocs.any(
      (d) => (d.data()['status'] as String?) == 'open',
    );
    if (hasPending) {
      throw StateError('La mesa tiene elementos pendientes en cocina.');
    }

    final batch = _db.batch();
    for (final doc in allTableOrders) {
      final itemsSnap = await doc.reference.collection('items').get();
      for (final itemDoc in itemsSnap.docs) {
        final itemStatus = (itemDoc.data()['status'] as String?) ?? '';
        if (itemStatus == 'todo' ||
            itemStatus == 'in_progress' ||
            itemStatus == 'ready') {
          batch.update(itemDoc.reference, {
            'status': 'served',
            'updatedAt': FieldValue.serverTimestamp(),
            'servedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    for (final doc in sessionDocs) {
      batch.update(doc.reference, {
        'status': 'closed',
        'updatedAt': FieldValue.serverTimestamp(),
        'tableClosedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return sessionDocs.isNotEmpty;
  }
}
