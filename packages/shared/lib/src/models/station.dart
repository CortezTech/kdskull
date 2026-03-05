import 'package:cloud_firestore/cloud_firestore.dart';

class Station {
  final String id;
  final String name;
  final int order;

  const Station({
    required this.id,
    required this.name,
    required this.order,
  });

  factory Station.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Station(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      order: (data['order'] as int?) ?? 0,
    );
  }
}
