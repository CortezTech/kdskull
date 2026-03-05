import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dish.dart';

class DishesRepository {
  DishesRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _dishes =>
      _db.collection('dishes');

  Stream<List<Dish>> watchAllDishes() {
    return _dishes
        .snapshots()
        .map((snap) => snap.docs.map(Dish.fromDoc).toList());
  }

  Stream<List<Dish>> watchAvailableDishes() {
    return _dishes
        .where('available', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(Dish.fromDoc).toList());
  }

  Future<void> createDish({
    required String name,
    required String stationId,
    required int stdPrepTimeSec,
    required bool available,
    required String category,
  }) async {
    final cat = category.trim().isEmpty ? 'Sin categoría' : category.trim();

    await _dishes.add({
      'name': name.trim(),
      'stationId': stationId,
      'stdPrepTimeSec': stdPrepTimeSec,
      'available': available,
      'category': cat,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDish({
    required String id,
    required String name,
    required String stationId,
    required int stdPrepTimeSec,
    required bool available,
    required String category,
  }) async {
    final cat = category.trim().isEmpty ? 'Sin categoría' : category.trim();

    await _dishes.doc(id).update({
      'name': name.trim(),
      'stationId': stationId,
      'stdPrepTimeSec': stdPrepTimeSec,
      'available': available,
      'category': cat,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDish(String id) async {
    await _dishes.doc(id).delete();
  }
}
