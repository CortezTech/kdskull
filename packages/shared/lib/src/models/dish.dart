import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/dish_categories.dart';

class Dish {
  final String id;
  final String name;
  final String stationId;
  final int stdPrepTimeSec;
  final bool available;
  final String category;

  const Dish({
    required this.id,
    required this.name,
    required this.stationId,
    required this.stdPrepTimeSec,
    required this.available,
    required this.category,
  });

  factory Dish.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Dish(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      stationId: (data['stationId'] as String?) ?? '',
      stdPrepTimeSec: (data['stdPrepTimeSec'] as int?) ?? 0,
      available: (data['available'] as bool?) ?? true,
      category: ((data['category'] as String?)?.trim().isNotEmpty == true)
          ? (data['category'] as String).trim()
          : kUncategorizedDishCategory,
    );
  }
}
