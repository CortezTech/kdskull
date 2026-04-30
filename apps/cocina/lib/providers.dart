import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

final stationsRepositoryProvider = Provider<StationsRepository>(
  (ref) => StationsRepository(ref.watch(firestoreProvider)),
);

final kitchenRepositoryProvider = Provider<KitchenRepository>(
  (ref) => KitchenRepository(ref.watch(firestoreProvider)),
);

final stationsProvider = StreamProvider<List<Station>>(
  (ref) => ref.watch(stationsRepositoryProvider).watchStations(),
);

// Estacion seleccionada (por defecto null hasta elegir).
final selectedStationIdProvider = StateProvider<String?>((_) => null);

final stationQueueProvider = StreamProvider<List<OrderItem>>((ref) {
  final stationId = ref.watch(selectedStationIdProvider);
  if (stationId == null) return const Stream<List<OrderItem>>.empty();
  return ref
      .watch(kitchenRepositoryProvider)
      .watchStationQueue(stationId: stationId);
});

final activeKitchenQueueProvider = StreamProvider<List<OrderItem>>(
  (ref) => ref.watch(kitchenRepositoryProvider).watchActiveQueue(),
);

final nowTickerProvider = StreamProvider<DateTime>((_) async* {
  yield DateTime.now();
  yield* Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});
