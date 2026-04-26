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
            return const Center(
              child: Text('No hay estaciones. Crea una primero.'),
            );
          }

          final stationNameById = {for (final s in stations) s.id: s.name};

          return dishesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error platos: $e')),
            data: (dishes) {
              if (dishes.isEmpty) {
                return const Center(child: Text('No hay platos'));
              }

              final dishesByCategory = <String, List<Dish>>{};
              for (final dish in dishes) {
                final category = dish.category.trim().isEmpty
                    ? 'Sin categoria'
                    : dish.category.trim();
                dishesByCategory.putIfAbsent(category, () => <Dish>[]).add(dish);
              }

              final categories = dishesByCategory.keys.toList()
                ..sort((a, b) {
                  final ia = kDefaultDishCategories.indexOf(a);
                  final ib = kDefaultDishCategories.indexOf(b);
                  if (ia != -1 && ib != -1) return ia.compareTo(ib);
                  if (ia != -1) return -1;
                  if (ib != -1) return 1;
                  return a.compareTo(b);
                });

              for (final category in categories) {
                final grouped = dishesByCategory[category]!;
                grouped.sort((a, b) {
                  final sa = stationNameById[a.stationId] ?? '';
                  final sb = stationNameById[b.stationId] ?? '';
                  final byStation = sa.compareTo(sb);
                  if (byStation != 0) return byStation;
                  return a.name.compareTo(b.name);
                });
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                itemCount: categories.length,
                itemBuilder: (context, categoryIndex) {
                  final category = categories[categoryIndex];
                  final categoryDishes = dishesByCategory[category]!;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
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
                              '$category (${categoryDishes.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          for (int i = 0; i < categoryDishes.length; i++) ...[
                            Builder(
                              builder: (context) {
                                final d = categoryDishes[i];
                                final stationName =
                                    stationNameById[d.stationId] ??
                                    '(sin estación)';
                                final minutes = (d.stdPrepTimeSec / 60).round();

                                return ListTile(
                                  title: Text(d.name),
                                  subtitle: Text(
                                    'Estación: $stationName · Tiempo: $minutes min',
                                  ),
                                  leading: Icon(
                                    d.available
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                  ),
                                  trailing: Wrap(
                                    spacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Switch(
                                        value: d.available,
                                        onChanged: (v) async {
                                          await ref
                                              .read(dishesRepositoryProvider)
                                              .updateDish(
                                                id: d.id,
                                                name: d.name,
                                                stationId: d.stationId,
                                                stdPrepTimeSec: d.stdPrepTimeSec,
                                                available: v,
                                                category: d.category,
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
                                          final ok = await _confirmDelete(
                                            context,
                                            d.name,
                                          );
                                          if (!ok) return;
                                          await ref
                                              .read(dishesRepositoryProvider)
                                              .deleteDish(d.id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if (i < categoryDishes.length - 1)
                              const Divider(height: 0),
                          ],
                        ],
                      ),
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

    final initMinutes = dish == null
        ? 10
        : (dish.stdPrepTimeSec / 60).round().clamp(1, 999);

    final minutesCtrl = TextEditingController(text: initMinutes.toString());

    var selectedStationId = dish?.stationId.isNotEmpty == true
        ? dish!.stationId
        : stations.first.id;

    var selectedCategory = (dish?.category.isNotEmpty == true)
        ? dish!.category
        : kDefaultDishCategories.first;
    final categoryOptions = _categoryOptions(selectedCategory);

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
                  initialValue: selectedCategory,
                  items: categoryOptions
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(
                    () => selectedCategory = v ?? kDefaultDishCategories.first,
                  ),
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStationId,
                  items: stations
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(
                    () => selectedStationId = v ?? stations.first.id,
                  ),
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
                    category: selectedCategory,
                  );
                } else {
                  await repo.updateDish(
                    id: dish.id,
                    name: name,
                    stationId: selectedStationId,
                    stdPrepTimeSec: sec,
                    available: available,
                    category: selectedCategory,
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

  List<String> _categoryOptions(String selectedCategory) {
    final normalizedSelected = selectedCategory.trim();
    final options = <String>[
      ...kDefaultDishCategories,
      if (normalizedSelected.isNotEmpty &&
          !kDefaultDishCategories.contains(normalizedSelected))
        normalizedSelected,
    ];
    return options;
  }
}
