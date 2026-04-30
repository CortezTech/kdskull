import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

final dishesRepositoryProvider = Provider<DishesRepository>(
  (ref) => DishesRepository(ref.watch(firestoreProvider)),
);

final ordersV2RepositoryProvider = Provider<OrdersV2Repository>(
  (ref) => OrdersV2Repository(ref.watch(firestoreProvider)),
);

final availableDishesProvider = StreamProvider<List<Dish>>(
  (ref) => ref.watch(dishesRepositoryProvider).watchAvailableDishes(),
);

final tableSessionsProvider = StreamProvider<Map<String, TableSessionState>>(
  (ref) => ref.watch(ordersV2RepositoryProvider).watchTableSessions(),
);

final tableReadyProgressByTableProvider =
    StreamProvider<Map<String, TableReadyProgress>>(
      (ref) => ref.watch(ordersV2RepositoryProvider).watchReadyProgressByTable(),
    );

final tableSessionProvider = Provider.family<TableSessionState?, String>(
  (ref, table) {
    final sessions = ref.watch(tableSessionsProvider).valueOrNull;
    return sessions?[table];
  },
);

final tableReadyProgressProvider = Provider.family<TableReadyProgress?, String>(
  (ref, table) {
    final map =
        ref.watch(tableReadyProgressByTableProvider).valueOrNull ??
        const <String, TableReadyProgress>{};
    return map[table];
  },
);

final selectedTableProvider = StateProvider<String?>((_) => null);
