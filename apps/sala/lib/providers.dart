import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';
import 'package:kds_shared/kds_shared.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ref.watch(firestoreProvider));
});

final newOrdersProvider = StreamProvider<List<KdsOrder>>((ref) {
  return ref.watch(ordersRepositoryProvider).watchNewOrders();
});

final dishesRepositoryProvider = Provider<DishesRepository>((ref) {
  return DishesRepository(ref.watch(firestoreProvider));
});

final availableDishesProvider = StreamProvider<List<Dish>>((ref) {
  return ref.watch(dishesRepositoryProvider).watchAvailableDishes();
});

final ordersV2RepositoryProvider = Provider<OrdersV2Repository>((ref) {
  return OrdersV2Repository(ref.watch(firestoreProvider));
});