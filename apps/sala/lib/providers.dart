import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
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

final tableSessionsProvider = StreamProvider<Map<String, TableSessionState>>((
  ref,
) {
  return ref.watch(ordersV2RepositoryProvider).watchTableSessions();
});

final tableSessionProvider = Provider.family<TableSessionState?, String>((
  ref,
  table,
) {
  final sessions = ref.watch(tableSessionsProvider).valueOrNull;
  return sessions?[table];
});

final tableReadyProgressByTableProvider =
    StreamProvider<Map<String, TableReadyProgress>>((ref) {
      return ref.watch(ordersV2RepositoryProvider).watchReadyProgressByTable();
    });

final tableReadyProgressProvider =
    Provider.family<TableReadyProgress?, String>((ref, table) {
      final map =
          ref.watch(tableReadyProgressByTableProvider).valueOrNull ??
          const <String, TableReadyProgress>{};
      return map[table];
    });

final selectedTableProvider = StateProvider<String?>((ref) => null);
