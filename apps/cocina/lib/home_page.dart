import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'widgets/kitchen_board.dart';
import 'widgets/station_title.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider);
    final selectedStationId = ref.watch(selectedStationIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: stationsAsync.when(
          loading: () => const KitchenStationTitleSkeleton(),
          error: (_, _) => const KitchenStationTitleSkeleton(),
          data: (stations) {
            if (stations.isEmpty) return const KitchenStationTitleSkeleton();
            final current = selectedStationId ?? stations.first.id;
            return KitchenStationTitleDropdown(
              current: current,
              stations: stations,
              onChanged: (v) =>
                  ref.read(selectedStationIdProvider.notifier).state = v,
            );
          },
        ),
      ),
      body: stationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error estaciones: $e')),
        data: (stations) {
          if (stations.isEmpty) {
            return const Center(
              child: Text('No hay estaciones (crea en Admin)'),
            );
          }

          final stationNamesById = <String, String>{
            for (final station in stations) station.id: station.name,
          };

          if (selectedStationId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedStationIdProvider.notifier).state =
                  stations.first.id;
            });
            return const Center(child: CircularProgressIndicator());
          }

          final queueAsync = ref.watch(stationQueueProvider);
          final activeQueueAsync = ref.watch(activeKitchenQueueProvider);
          return queueAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error cola: $e')),
            data: (items) => activeQueueAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error cola global: $e')),
              data: (allActiveItems) => KitchenBoard(
                items: items,
                allActiveItems: allActiveItems,
                stationNamesById: stationNamesById,
              ),
            ),
          );
        },
      ),
    );
  }
}
