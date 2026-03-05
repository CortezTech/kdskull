import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station.dart';

class StationsRepository {
  StationsRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _stations =>
      _db.collection('stations');

  Stream<List<Station>> watchStations() {
    return _stations
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(Station.fromDoc).toList());
  }

  Future<void> createStation({
    required String name,
    required int order,
  }) async {
    await _stations.add({
      'name': name.trim(),
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStation({
    required String id,
    required String name,
    required int order,
  }) async {
    await _stations.doc(id).update({
      'name': name.trim(),
      'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteStation(String id) async {
    await _stations.doc(id).delete();
  }
}
