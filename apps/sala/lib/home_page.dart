import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'cart.dart';
import 'providers.dart';
import 'table_select_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(availableDishesProvider);

    final table = ref.watch(selectedTableProvider);
    final session = table == null ? null : ref.watch(tableSessionProvider(table));
    final progress = table == null ? null : ref.watch(tableReadyProgressProvider(table));
    final readyCount = progress?.readyQty ?? (session?.doneOrders ?? 0);
    final totalCount = progress?.totalQty ?? (session?.doneOrders ?? 0);
    final hasProgress = totalCount > 0;
    final allReady = hasProgress && readyCount >= totalCount;
    final noneReady = hasProgress && readyCount == 0;
    final readyChipColor = allReady
        ? const Color(0xFF2E7D32)
        : noneReady
        ? const Color(0xFFB3261E)
        : const Color(0xFFD97706);
    final cartMap = ref.watch(cartByTableProvider);

    final cart = table == null
        ? <CartLine>[]
        : (cartMap[table] ?? <CartLine>[]);
    final totalItems = cart.fold<int>(0, (acc, l) => acc + l.qty);
    final isCompactTopBar = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa ${table ?? "-"}'),
        actions: [
          if (table != null && !isCompactTopBar)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (session?.isOpen ?? false)
                            ? const Color(0xFF2E7D32).withValues(alpha: 0.14)
                            : const Color(0xFF5E6E89).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        (session?.isOpen ?? false) ? 'Mesa abierta' : 'Mesa nueva',
                        style: TextStyle(
                          color: (session?.isOpen ?? false)
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF5E6E89),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (totalCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: readyChipColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$readyCount/$totalCount listo${totalCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: readyChipColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (table != null && !isCompactTopBar)
            TextButton(
              onPressed: (session?.canClose ?? false)
                  ? () => _closeTable(context, ref, table, session!)
                  : null,
              child: const Text('Cerrar mesa'),
            ),
          if (table != null && isCompactTopBar)
            IconButton(
              tooltip: 'Cerrar mesa',
              onPressed: (session?.canClose ?? false)
                  ? () => _closeTable(context, ref, table, session!)
                  : null,
              icon: const Icon(Icons.task_alt_rounded),
            ),
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

          final grouped = <String, List<Dish>>{};
          for (final dish in dishes) {
            final category = dish.category.isEmpty
                ? kUncategorizedDishCategory
                : dish.category;
            grouped.putIfAbsent(category, () => []).add(dish);
          }
          for (final list in grouped.values) {
            list.sort((a, b) => a.name.compareTo(b.name));
          }

          final categories = buildDishCategoryOrder(grouped.keys);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8FAFF), Color(0xFFEEF3FB), Color(0xFFE7EEF9)],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                  children: [
                    if (isCompactTopBar && table != null)
                      _CompactTableStatusBar(
                        isOpen: session?.isOpen ?? false,
                        readyCount: readyCount,
                        totalCount: totalCount,
                        readyChipColor: readyChipColor,
                      ),
                    if (isCompactTopBar && table != null)
                      const SizedBox(height: 12),
                    for (int i = 0; i < categories.length; i++) ...[
                      _CategorySection(
                        category: categories[i],
                        dishes: grouped[categories[i]]!,
                      ),
                      if (i < categories.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _closeTable(
    BuildContext context,
    WidgetRef ref,
    String table,
    TableSessionState session,
  ) async {
    if (!session.canClose) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No puedes cerrar la mesa hasta que cocina termine todos los elementos.',
            ),
          ),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar mesa'),
        content: Text('Quieres cerrar la mesa $table?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final closed = await ref
          .read(ordersV2RepositoryProvider)
          .closeTableIfReady(table);

      if (!context.mounted) return;
      if (!closed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay pedidos abiertos para esa mesa.')),
        );
        return;
      }

      ref.read(cartByTableProvider.notifier).clearTable(table);
      ref.read(selectedTableProvider.notifier).state = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesa $table cerrada correctamente.')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TableSelectPage()),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se puede cerrar la mesa: hay elementos pendientes en cocina.',
            ),
          ),
        );
      }
    }
  }

  void _openCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CartSheet(),
    );
  }
}

class _CompactTableStatusBar extends StatelessWidget {
  const _CompactTableStatusBar({
    required this.isOpen,
    required this.readyCount,
    required this.totalCount,
    required this.readyChipColor,
  });

  final bool isOpen;
  final int readyCount;
  final int totalCount;
  final Color readyChipColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isOpen
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF5E6E89))
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isOpen ? 'Mesa abierta' : 'Mesa nueva',
                style: TextStyle(
                  color: isOpen
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF5E6E89),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            if (totalCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: readyChipColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$readyCount/$totalCount listo${totalCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: readyChipColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
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

    final minutes = (dish.stdPrepTimeSec / 60).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E7F3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2233),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tiempo: $minutes min',
                  style: const TextStyle(
                    color: Color(0xFF5E6E89),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: () => _openDishConfig(context, ref, table),
            icon: const Icon(Icons.add),
            label: const Text('Anadir'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDishConfig(
    BuildContext context,
    WidgetRef ref,
    String table,
  ) async {
    final notesController = TextEditingController();
    int qty = 1;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  dish.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tiempo estimado: ${(dish.stdPrepTimeSec / 60).round()} min',
                  style: const TextStyle(color: Color(0xFF5E6E89)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Cantidad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: qty > 1 ? () => setState(() => qty--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => qty++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Comentario (opcional)',
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
                        onPressed: () {
                          ref.read(cartByTableProvider.notifier).add(
                                table,
                                dish,
                                notes: notesController.text.trim(),
                                qty: qty,
                              );
                          Navigator.pop(context);
                        },
                        child: const Text('Anadir al carrito'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.dishes});

  final String category;
  final List<Dish> dishes;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E6BA8).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 16,
                      color: Color(0xFF0E6BA8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: Color(0xFF1A2233),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E6BA8).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${dishes.length}',
                      style: const TextStyle(
                        color: Color(0xFF0E6BA8),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < dishes.length; i++) ...[
              DishRow(dish: dishes[i]),
              if (i < dishes.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
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
                    'Carrito - Mesa ${table ?? "-"} ($totalItems)',
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
                    ? const Center(child: Text('Carrito vacio'))
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: cart.length,
                        separatorBuilder: (_, _) => const Divider(height: 0),
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
                                            .removeOne(
                                              table,
                                              line.dish,
                                              preferredNotes: line.notes,
                                            ),
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
                                            .add(
                                              table,
                                              line.dish,
                                              notes: line.notes,
                                            ),
                                  icon: const Icon(Icons.add),
                                ),
                                IconButton(
                                  tooltip: 'Notas',
                                  onPressed: table == null
                                      ? null
                                      : () => _openLineNotes(
                                            context,
                                            ref,
                                            table,
                                            line,
                                          ),
                                  icon: const Icon(Icons.edit_note),
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
                          try {
                            final lines = cart
                                .map(
                                  (l) => (
                                    dish: l.dish,
                                    qty: l.qty,
                                    notes: l.notes,
                                  ),
                                )
                                .toList();

                            await ref
                                .read(ordersV2RepositoryProvider)
                                .createOrderWithItems(
                                  table: table,
                                  lines: lines,
                                );

                            ref
                                .read(cartByTableProvider.notifier)
                                .clearTable(table);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pedido enviado a cocina'),
                                ),
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No se pudo enviar el pedido. Intenta de nuevo.',
                                  ),
                                ),
                              );
                            }
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

  Future<void> _openLineNotes(
    BuildContext context,
    WidgetRef ref,
    String table,
    CartLine line,
  ) async {
    final controller = TextEditingController(text: line.notes);

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
                'Notas - ${line.dish.name}',
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

    ref.read(cartByTableProvider.notifier).setNotesForLine(
      table,
      line.dish.id,
      fromNotes: line.notes,
      toNotes: result,
    );
  }
}
