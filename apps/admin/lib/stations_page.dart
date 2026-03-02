import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'providers.dart';

class StationsPage extends ConsumerWidget {
  const StationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estaciones')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openStationDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      body: stationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stations) {
          if (stations.isEmpty) {
            return const Center(child: Text('No hay estaciones'));
          }
          return ListView.separated(
            itemCount: stations.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final s = stations[i];
              return ListTile(
                title: Text(s.name),
                subtitle: Text('Orden: ${s.order}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openStationDialog(
                        context,
                        ref,
                        station: s,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Borrar',
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final ok = await _confirmDelete(context, s.name);
                        if (!ok) return;
                        await ref
                            .read(stationsRepositoryProvider)
                            .deleteStation(s.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Borrar estación'),
            content: Text('¿Seguro que quieres borrar "$name"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Borrar'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _openStationDialog(
    BuildContext context,
    WidgetRef ref, {
    Station? station,
  }) async {
    final nameCtrl = TextEditingController(text: station?.name ?? '');
    final orderCtrl = TextEditingController(
      text: (station?.order ?? 0).toString(),
    );

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(station == null ? 'Añadir estación' : 'Editar estación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: orderCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Orden'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final order = int.tryParse(orderCtrl.text.trim()) ?? 0;

              if (name.isEmpty) return;

              final repo = ref.read(stationsRepositoryProvider);
              if (station == null) {
                await repo.createStation(name: name, order: order);
              } else {
                await repo.updateStation(id: station.id, name: name, order: order);
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}