import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'providers.dart';
import 'widgets/confirm_delete_dialog.dart';
import 'widgets/station_form_dialog.dart';

class StationsPage extends ConsumerWidget {
  const StationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estaciones')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleUpsert(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('A\u00F1adir'),
      ),
      body: stationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stations) {
          if (stations.isEmpty) {
            return const Center(child: Text('No hay estaciones'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Text(
                          'Estaciones (${stations.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      for (int i = 0; i < stations.length; i++) ...[
                        _StationTile(
                          station: stations[i],
                          onEdit: (station) =>
                              _handleUpsert(context, ref, station: station),
                        ),
                        if (i < stations.length - 1) const Divider(height: 0),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleUpsert(
    BuildContext context,
    WidgetRef ref, {
    Station? station,
  }) async {
    final values = await showStationFormDialog(
      context: context,
      initialStation: station,
    );
    if (values == null) return;

    final repo = ref.read(stationsRepositoryProvider);
    if (station == null) {
      await repo.createStation(name: values.name, order: values.order);
    } else {
      await repo.updateStation(
        id: station.id,
        name: values.name,
        order: values.order,
      );
    }
  }
}

class _StationTile extends ConsumerWidget {
  const _StationTile({required this.station, required this.onEdit});

  final Station station;
  final Future<void> Function(Station station) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.kitchen_rounded),
      title: Text(station.name),
      subtitle: Text('Orden: ${station.order}'),
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit),
            onPressed: () => onEdit(station),
          ),
          IconButton(
            tooltip: 'Borrar',
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showConfirmDeleteDialog(
                context: context,
                title: 'Borrar estaci\u00F3n',
                message: '\u00BFSeguro que quieres borrar "${station.name}"?',
              );
              if (!ok) return;
              await ref
                  .read(stationsRepositoryProvider)
                  .deleteStation(station.id);
            },
          ),
        ],
      ),
    );
  }
}
