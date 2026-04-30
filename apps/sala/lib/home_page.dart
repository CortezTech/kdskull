import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'cart.dart';
import 'providers.dart';
import 'table_select_page.dart';
import 'widgets/cart_sheet.dart';
import 'widgets/category_section.dart';
import 'widgets/compact_table_status_bar.dart';
import 'widgets/table_progress_utils.dart';
import 'widgets/top_status_actions.dart';

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
    final readyColor = readyChipColor(
      readyCount: readyCount,
      totalCount: totalCount,
    );

    final cartMap = ref.watch(cartByTableProvider);
    final cart = table == null ? <CartLine>[] : (cartMap[table] ?? <CartLine>[]);
    final totalItems = cart.fold<int>(0, (acc, l) => acc + l.qty);
    final isCompactTopBar = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa ${table ?? "-"}'),
        actions: [
          if (table != null && !isCompactTopBar)
            TopStatusActions(
              isOpen: session?.isOpen ?? false,
              readyCount: readyCount,
              totalCount: totalCount,
              readyChipColor: readyColor,
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
                      child: Text('$totalItems', style: const TextStyle(fontSize: 11)),
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
                      CompactTableStatusBar(
                        isOpen: session?.isOpen ?? false,
                        readyCount: readyCount,
                        totalCount: totalCount,
                        readyChipColor: readyColor,
                      ),
                    if (isCompactTopBar && table != null) const SizedBox(height: 12),
                    for (int i = 0; i < categories.length; i++) ...[
                      CategorySection(
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
      final closed = await ref.read(ordersV2RepositoryProvider).closeTableIfReady(table);
      if (!context.mounted) return;
      if (!closed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay pedidos abiertos para esa mesa.')),
        );
        return;
      }

      ref.read(cartByTableProvider.notifier).clearTable(table);
      ref.read(selectedTableProvider.notifier).state = null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mesa $table cerrada correctamente.')));
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
      builder: (_) => const CartSheet(),
    );
  }
}
