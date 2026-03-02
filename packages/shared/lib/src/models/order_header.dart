import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHeader {
  final String id;
  final String table;
  final String status; // open | done | cancelled
  final DateTime? createdAt;

  const OrderHeader({
    required this.id,
    required this.table,
    required this.status,
    required this.createdAt,
  });

  factory OrderHeader.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdTs = data['createdAt'];
    return OrderHeader(
      id: doc.id,
      table: (data['table'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'open',
      createdAt: createdTs is Timestamp ? createdTs.toDate() : null,
    );
  }
}