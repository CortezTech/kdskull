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

// estación seleccionada (por defecto null hasta elegir)
final selectedStationIdProvider = StateProvider<String?>((ref) => null);

final kitchenRepositoryProvider = Provider<KitchenRepository>((ref) {
  return KitchenRepository(ref.watch(firestoreProvider));
});

final stationQueueProvider = StreamProvider<List<OrderItem>>((ref) {
  final stationId = ref.watch(selectedStationIdProvider);
  if (stationId == null) return const Stream.empty();
  return ref.watch(kitchenRepositoryProvider).watchStationQueue(stationId: stationId);
});