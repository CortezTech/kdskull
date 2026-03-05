import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'providers.dart';
import 'cart.dart';
import 'table_select_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(availableDishesProvider);

    final table = ref.watch(selectedTableProvider);
    final cartMap = ref.watch(cartByTableProvider);

    final cart = table == null
        ? <CartLine>[]
        : (cartMap[table] ?? <CartLine>[]);
    final totalItems = cart.fold<int>(0, (acc, l) => acc + l.qty);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sala - Mesa ${table ?? "-"}'),
        actions: [
          // Cambiar mesa
          IconButton(
            tooltip: 'Cambiar mesa',
            icon: const Icon(Icons.table_restaurant),
            onPressed: () {
              ref.read(selectedTableProvider.notifier).state = null;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const TableSelectPage()),
              );
            },
          ),

          // Carrito con badge (carrito de la mesa actual)
          IconButton(
            tooltip: 'Carrito',
            onPressed: cart.isEmpty ? null : () => _openCartSheet(context),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (totalItems > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: CircleAvatar(
                      radius: 9,
                      child: Text(
                        '$totalItems',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: dishesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (dishes) {
          if (dishes.isEmpty) {
            return const Center(child: Text('No hay platos disponibles (86)'));
          }

          // Agrupar platos por categoría
          final grouped = <String, List<Dish>>{};
          for (final d in dishes) {
            final cat = d.category.isEmpty ? 'Sin categoría' : d.category;
            grouped.putIfAbsent(cat, () => []).add(d);
          }

          const order = [
            'Entrantes',
            'Principal',
            'Postres',
            'Bebidas',
            'Otros',
            'Sin categoría',
          ];
          final categories = order.where(grouped.containsKey).toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final category = categories[i];
              final dishesInCategory = grouped[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...dishesInCategory.map((d) => DishRow(dish: d)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _openCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CartSheet(),
    );
  }
}

class DishRow extends ConsumerWidget {
  const DishRow({super.key, required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final table = ref.watch(selectedTableProvider);
    if (table == null) return const SizedBox.shrink();

    final cartNotifier = ref.read(cartByTableProvider.notifier);

    // qty reactivo solo para este dish y mesa (optimiza rebuilds)
    final qty = ref.watch(
      cartByTableProvider.select((map) {
        final lines = map[table] ?? const <CartLine>[];
        final i = lines.indexWhere((l) => l.dish.id == dish.id);
        return i == -1 ? 0 : lines[i].qty;
      }),
    );

    final minutes = (dish.stdPrepTimeSec / 60).round();

    return ListTile(
      title: Text(dish.name),
      subtitle: Text('Tiempo: $minutes min'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: qty == 0
                ? null
                : () => cartNotifier.removeOne(table, dish),
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$qty',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          IconButton(
            onPressed: () => cartNotifier.add(table, dish),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Notas',
            onPressed: qty == 0 ? null : () => _openNotes(context, ref, table),
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
    );
  }

  Future<void> _openNotes(
    BuildContext context,
    WidgetRef ref,
    String table,
  ) async {
    // Buscar notas actuales de este plato en el carrito de esta mesa
    final map = ref.read(cartByTableProvider);
    final lines = map[table] ?? const <CartLine>[];

    final currentNotes =
        lines
            .where((l) => l.dish.id == dish.id)
            .map((l) => l.notes)
            .firstOrNull ??
        '';

    final controller = TextEditingController(text: currentNotes);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Notas · ${dish.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ej: sin cebolla, alergia, punto de carne...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, controller.text.trim()),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    ref.read(cartByTableProvider.notifier).setNotes(table, dish.id, result);
  }
}

extension _FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _CartSheet extends ConsumerWidget {
  const _CartSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final table = ref.watch(selectedTableProvider);
    final cartMap = ref.watch(cartByTableProvider);

    final cart = table == null
        ? <CartLine>[]
        : (cartMap[table] ?? <CartLine>[]);

    final totalItems = cart.fold<int>(0, (acc, l) => acc + l.qty);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Carrito · Mesa ${table ?? "-"} ($totalItems)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: (table == null || cart.isEmpty)
                        ? null
                        : () => ref
                              .read(cartByTableProvider.notifier)
                              .clearTable(table),
                    child: const Text('Vaciar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: cart.isEmpty
                    ? const Center(child: Text('Carrito vacío'))
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: cart.length,
                        separatorBuilder: (_, __) => const Divider(height: 0),
                        itemBuilder: (context, i) {
                          final line = cart[i];
                          return ListTile(
                            title: Text(line.dish.name),
                            subtitle: line.notes.isEmpty
                                ? null
                                : Text('Notas: ${line.notes}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: table == null
                                      ? null
                                      : () => ref
                                            .read(cartByTableProvider.notifier)
                                            .removeOne(table, line.dish),
                                  icon: const Icon(Icons.remove),
                                ),
                                SizedBox(
                                  width: 28,
                                  child: Center(
                                    child: Text(
                                      '${line.qty}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: table == null
                                      ? null
                                      : () => ref
                                            .read(cartByTableProvider.notifier)
                                            .add(table, line.dish),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (table == null || cart.isEmpty)
                      ? null
                      : () async {
                          // Construir lines desde el carrito de esta mesa
                          final lines = cart
                              .map(
                                (l) =>
                                    (dish: l.dish, qty: l.qty, notes: l.notes),
                              )
                              .toList();

                          await ref
                              .read(ordersV2RepositoryProvider)
                              .createOrderWithItems(table: table, lines: lines);

                          // Limpiar solo el carrito de esta mesa
                          ref
                              .read(cartByTableProvider.notifier)
                              .clearTable(table);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pedido enviado a cocina ✅'),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar a cocina'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
