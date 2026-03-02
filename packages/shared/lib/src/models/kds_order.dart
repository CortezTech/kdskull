import 'package:cloud_firestore/cloud_firestore.dart';
import 'kds_order_item.dart';

class KdsOrder {
  final String id;
  final String status;
  final String tableId;
  final List<KdsOrderItem> items;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KdsOrder({
    required this.id,
    required this.status,
    required this.tableId,
    required this.items,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KdsOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final createdTs = data['createdAt'];
    final updatedTs = data['updatedAt'];

    final rawItems = (data['items'] as List?) ?? const [];
    final items = rawItems
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .map(KdsOrderItem.fromMap)
        .toList();

    return KdsOrder(
      id: doc.id,
      status: (data['status'] as String?) ?? 'new',
      tableId: (data['tableId'] as String?) ?? 'T1',
      notes: (data['notes'] as String?) ?? '',
      items: items,
      createdAt: createdTs is Timestamp ? createdTs.toDate() : null,
      updatedAt: updatedTs is Timestamp ? updatedTs.toDate() : null,
    );
  }
}