import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

final stationsRepositoryProvider = Provider<StationsRepository>(
  (ref) => StationsRepository(ref.watch(firestoreProvider)),
);

final dishesRepositoryProvider = Provider<DishesRepository>(
  (ref) => DishesRepository(ref.watch(firestoreProvider)),
);

final stationsProvider = StreamProvider<List<Station>>(
  (ref) => ref.watch(stationsRepositoryProvider).watchStations(),
);

final dishesProvider = StreamProvider<List<Dish>>(
  (ref) => ref.watch(dishesRepositoryProvider).watchAllDishes(),
);
