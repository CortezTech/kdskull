import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'providers.dart';

class DishesPage extends ConsumerWidget {
  const DishesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider);
    final dishesAsync = ref.watch(dishesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Platos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final stations = stationsAsync.value ?? const <Station>[];
          if (stations.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Crea una estación primero.')),
            );
            return;
          }
          await _openDishDialog(context, ref, stations: stations);
        },
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      body: stationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error estaciones: $e')),
        data: (stations) {
          if (stations.isEmpty) {
            return const Center(child: Text('No hay estaciones. Crea una primero.'));
          }

          // Mapa stationId -> name para mostrar en la lista
          final stationNameById = {
            for (final s in stations) s.id: s.name,
          };

          return dishesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error platos: $e')),
            data: (dishes) {
              if (dishes.isEmpty) {
                return const Center(child: Text('No hay platos'));
              }

              // (Opcional) Ordenar por estación y nombre para una lista más limpia
              final sorted = [...dishes]..sort((a, b) {
                  final sa = stationNameById[a.stationId] ?? '';
                  final sb = stationNameById[b.stationId] ?? '';
                  final c1 = sa.compareTo(sb);
                  if (c1 != 0) return c1;
                  return a.name.compareTo(b.name);
                });

              return ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  final d = sorted[i];
                  final stationName = stationNameById[d.stationId] ?? '(sin estación)';
                  final minutes = (d.stdPrepTimeSec / 60).round();

                  return ListTile(
                    title: Text(d.name),
                    subtitle: Text('Estación: $stationName · Tiempo: ${minutes} min'),
                    leading: Icon(
                      d.available ? Icons.check_circle : Icons.cancel,
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Switch 86 (available)
                        Switch(
                          value: d.available,
                          onChanged: (v) async {
                            await ref.read(dishesRepositoryProvider).updateDish(
                                  id: d.id,
                                  name: d.name,
                                  stationId: d.stationId,
                                  stdPrepTimeSec: d.stdPrepTimeSec,
                                  available: v,
                                );
                          },
                        ),
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openDishDialog(
                            context,
                            ref,
                            stations: stations,
                            dish: d,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Borrar',
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final ok = await _confirmDelete(context, d.name);
                            if (!ok) return;
                            await ref.read(dishesRepositoryProvider).deleteDish(d.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
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
            title: const Text('Borrar plato'),
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

  Future<void> _openDishDialog(
    BuildContext context,
    WidgetRef ref, {
    required List<Station> stations,
    Dish? dish,
  }) async {
    final nameCtrl = TextEditingController(text: dish?.name ?? '');

    // UI en minutos, guardado en segundos
    final initMinutes = dish == null
        ? 10
        : (dish.stdPrepTimeSec / 60).round().clamp(1, 999);

    final minutesCtrl = TextEditingController(text: initMinutes.toString());

    var selectedStationId = dish?.stationId.isNotEmpty == true
        ? dish!.stationId
        : stations.first.id;

    var available = dish?.available ?? true;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(dish == null ? 'Añadir plato' : 'Editar plato'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStationId,
                  items: stations
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedStationId = v ?? stations.first.id),
                  decoration: const InputDecoration(labelText: 'Estación'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: minutesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo estándar (minutos)',
                    helperText: 'Se guarda en segundos en Firestore',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: available,
                  onChanged: (v) => setState(() => available = v),
                  title: const Text('Disponible'),
                  subtitle: const Text('Si está desactivado, actúa como 86'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final minutes = int.tryParse(minutesCtrl.text.trim()) ?? 0;
                final sec = (minutes <= 0 ? 60 : minutes * 60);

                if (name.isEmpty) return;

                final repo = ref.read(dishesRepositoryProvider);
                if (dish == null) {
                  await repo.createDish(
                    name: name,
                    stationId: selectedStationId,
                    stdPrepTimeSec: sec,
                    available: available,
                  );
                } else {
                  await repo.updateDish(
                    id: dish.id,
                    name: name,
                    stationId: selectedStationId,
                    stdPrepTimeSec: sec,
                    available: available,
                  );
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}