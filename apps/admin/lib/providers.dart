import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final stationsRepositoryProvider = Provider<StationsRepository>((ref) {
  return StationsRepository(ref.watch(firestoreProvider));
});

final stationsProvider = StreamProvider<List<Station>>((ref) {
  return ref.watch(stationsRepositoryProvider).watchStations();
});

final dishesRepositoryProvider = Provider<DishesRepository>((ref) {
  return DishesRepository(ref.watch(firestoreProvider));
});

final dishesProvider = StreamProvider<List<Dish>>((ref) {
  return ref.watch(dishesRepositoryProvider).watchAllDishes();
});