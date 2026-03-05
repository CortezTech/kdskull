import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String table;
  final String dishId;
  final String dishName;
  final String stationId;
  final int stdPrepTimeSec;
  final String status; // todo | in_progress | ready
  final int qty;
  final String notes;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? readyAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.table,
    required this.dishId,
    required this.dishName,
    required this.stationId,
    required this.stdPrepTimeSec,
    required this.status,
    required this.qty,
    required this.notes,
    required this.createdAt,
    required this.startedAt,
    required this.readyAt,
  });

  factory OrderItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

    return OrderItem(
      id: doc.id,
      orderId: (data['orderId'] as String?) ?? '',
      table: (data['table'] as String?) ?? '',
      dishId: (data['dishId'] as String?) ?? '',
      dishName: (data['dishName'] as String?) ?? '',
      stationId: (data['stationId'] as String?) ?? '',
      stdPrepTimeSec: (data['stdPrepTimeSec'] as int?) ?? 0,
      status: (data['status'] as String?) ?? 'todo',
      qty: (data['qty'] as int?) ?? 1,
      notes: (data['notes'] as String?) ?? '',
      createdAt: _ts(data['createdAt']),
      startedAt: _ts(data['startedAt']),
      readyAt: _ts(data['readyAt']),
    );
  }
}
