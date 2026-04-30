import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_item.dart';

class KitchenRepository {
  KitchenRepository(this._db);

  final FirebaseFirestore _db;

  /// Lee TODOS los items (de todos los pedidos) por estación y estados.
  Stream<List<OrderItem>> watchStationQueue({
    required String stationId,
    List<String> statuses = const ['todo', 'in_progress', 'ready'],
  }) {
    return _db
        .collectionGroup('items')
        .where('stationId', isEqualTo: stationId)
        .where('status', whereIn: statuses)
        .snapshots()
        .map((snap) => snap.docs.map(OrderItem.fromDoc).toList());
  }

  /// Lee todos los items activos, sin filtrar por estación.
  Stream<List<OrderItem>> watchActiveQueue({
    List<String> statuses = const ['todo', 'in_progress', 'ready'],
  }) {
    return _db
        .collectionGroup('items')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(OrderItem.fromDoc)
              .where((item) => statuses.contains(item.status))
              .toList(),
        );
  }

  /// Cambia estado y setea timestamps coherentes.
  Future<void> setItemStatus({
    required String orderId,
    required String itemId,
    required String status,
  }) async {
    final orderRef = _db.collection('orders').doc(orderId);
    final itemRef = orderRef.collection('items').doc(itemId);

    await _db.runTransaction((tx) async {
      // 1) Leer item actual
      final itemSnap = await tx.get(itemRef);
      final itemData = itemSnap.data() ?? <String, dynamic>{};
      final prevStatus = (itemData['status'] as String?) ?? 'todo';

      // 2) Leer pedido actual
      final orderSnap = await tx.get(orderRef);
      final orderData = orderSnap.data() ?? <String, dynamic>{};
      final prevRemaining = (orderData['remainingItems'] as int?) ?? 0;

      // 3) Actualizar item
      final update = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == 'in_progress' && itemData['startedAt'] == null) {
        update['startedAt'] = FieldValue.serverTimestamp();
      }
      if (status == 'ready') {
        update['readyAt'] = FieldValue.serverTimestamp();
      }

      tx.update(itemRef, update);

      // 4) Autocierre: solo si pasa de NO-ready -> ready
      if (prevStatus != 'ready' && status == 'ready') {
        final nextRemaining = (prevRemaining - 1).clamp(0, 1 << 30);

        final orderUpdate = <String, dynamic>{
          'remainingItems': nextRemaining,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (nextRemaining == 0) {
          orderUpdate['status'] = 'done';
          orderUpdate['closedAt'] = FieldValue.serverTimestamp();
        }

        tx.update(orderRef, orderUpdate);
      }
    });
  }
}
