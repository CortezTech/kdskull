import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kds_order.dart';
import '../models/kds_order_item.dart';


class OrdersRepository {
  OrdersRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

Stream<List<KdsOrder>> watchNewOrders() {
  return _orders
      .where('status', isEqualTo: 'new')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(KdsOrder.fromDoc).toList());
}

  Stream<List<KdsOrder>> watchKitchenQueue() {
    return _orders
        .where('status', whereIn: ['new', 'preparing', 'ready'])
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(KdsOrder.fromDoc).toList());
  }

  Future<void> updateStatus({
    required String orderId,
    required String status,
  }) async {
    await _orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

Future<void> createOrder({
  required String tableId,
  required List<KdsOrderItem> items,
  String notes = '',
}) async {
  await _orders.add({
    'status': 'new',
    'tableId': tableId,
    'notes': notes,
    'items': items.map((i) => i.toMap()).toList(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}