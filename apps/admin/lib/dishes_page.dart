import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'providers.dart';
import 'widgets/confirm_delete_dialog.dart';
import 'widgets/dish_form_dialog.dart';

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
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Crea una estaci\u00F3n primero.'),
                ),
              );
            }
            return;
          }
          await _handleUpsert(context, ref, stations: stations);
        },
        icon: const Icon(Icons.add),
        label: const Text('A\u00F1adir'),
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

              final grouped = _groupAndSortDishes(dishes, stationNameById);
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                itemCount: grouped.length,
                itemBuilder: (context, i) {
                  final entry = grouped.entries.elementAt(i);
                  return _DishCategoryCard(
                    category: entry.key,
                    dishes: entry.value,
                    stations: stations,
                    stationNameById: stationNameById,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleUpsert(
    BuildContext context,
    WidgetRef ref, {
    required List<Station> stations,
    Dish? dish,
  }) async {
    final values = await showDishFormDialog(
      context: context,
      stations: stations,
      initialDish: dish,
    );
    if (values == null) return;

    final repo = ref.read(dishesRepositoryProvider);
    if (dish == null) {
      await repo.createDish(
        name: values.name,
        stationId: values.stationId,
        stdPrepTimeSec: values.stdPrepTimeSec,
        available: values.available,
        category: values.category,
      );
    } else {
      await repo.updateDish(
        id: dish.id,
        name: values.name,
        stationId: values.stationId,
        stdPrepTimeSec: values.stdPrepTimeSec,
        available: values.available,
        category: values.category,
      );
    }
  }
}

class _DishCategoryCard extends StatelessWidget {
  const _DishCategoryCard({
    required this.category,
    required this.dishes,
    required this.stations,
    required this.stationNameById,
  });

  final String category;
  final List<Dish> dishes;
  final List<Station> stations;
  final Map<String, String> stationNameById;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                '$category (${dishes.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 1),
            for (int i = 0; i < dishes.length; i++) ...[
              _DishTile(
                dish: dishes[i],
                stations: stations,
                stationNameById: stationNameById,
              ),
              if (i < dishes.length - 1) const Divider(height: 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _DishTile extends ConsumerWidget {
  const _DishTile({
    required this.dish,
    required this.stations,
    required this.stationNameById,
  });

  final Dish dish;
  final List<Station> stations;
  final Map<String, String> stationNameById;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationName =
        stationNameById[dish.stationId] ?? '(sin estaci\u00F3n)';
    final minutes = (dish.stdPrepTimeSec / 60).round();

    return ListTile(
      title: Text(dish.name),
      subtitle: Text('Estaci\u00F3n: $stationName \u00B7 Tiempo: $minutes min'),
      leading: Icon(dish.available ? Icons.check_circle : Icons.cancel),
      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Switch(
            value: dish.available,
            onChanged: (v) async {
              await ref
                  .read(dishesRepositoryProvider)
                  .updateDish(
                    id: dish.id,
                    name: dish.name,
                    stationId: dish.stationId,
                    stdPrepTimeSec: dish.stdPrepTimeSec,
                    available: v,
                    category: dish.category,
                  );
            },
          ),
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final values = await showDishFormDialog(
                context: context,
                stations: stations,
                initialDish: dish,
              );
              if (values == null) return;
              await ref
                  .read(dishesRepositoryProvider)
                  .updateDish(
                    id: dish.id,
                    name: values.name,
                    stationId: values.stationId,
                    stdPrepTimeSec: values.stdPrepTimeSec,
                    available: values.available,
                    category: values.category,
                  );
            },
          ),
          IconButton(
            tooltip: 'Borrar',
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showConfirmDeleteDialog(
                context: context,
                title: 'Borrar plato',
                message: '\u00BFSeguro que quieres borrar "${dish.name}"?',
              );
              if (!ok) return;
              await ref.read(dishesRepositoryProvider).deleteDish(dish.id);
            },
          ),
        ],
      ),
    );
  }
}

Map<String, List<Dish>> _groupAndSortDishes(
  List<Dish> dishes,
  Map<String, String> stationNameById,
) {
  final dishesByCategory = <String, List<Dish>>{};
  for (final dish in dishes) {
    final category = dish.category.trim().isEmpty
        ? 'Sin categor\u00EDa'
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

  return {
    for (final category in categories) category: dishesByCategory[category]!,
  };
}
