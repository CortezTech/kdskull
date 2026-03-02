import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dish.dart';

class OrdersV2Repository {
  OrdersV2Repository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _orders => _db.collection('orders');

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
}