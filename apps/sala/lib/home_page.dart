import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'providers.dart';
import 'cart.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(availableDishesProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sala - Carta')),
      bottomNavigationBar: _CartBar(cart: cart),
      body: dishesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (dishes) {
          if (dishes.isEmpty) {
            return const Center(child: Text('No hay platos disponibles (86)'));
          }
          return ListView.separated(
            itemCount: dishes.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final d = dishes[i];
              final minutes = (d.stdPrepTimeSec / 60).round();
              return ListTile(
                title: Text(d.name),
                subtitle: Text('Tiempo: $minutes min'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => ref.read(cartProvider.notifier).add(d),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: cart.isEmpty
            ? null
            : () async {
                // Mesa fija por ahora; luego hacemos selector 1..6 como en dataset
                const table = '1';

                final lines = cart
                    .map((l) => (dish: l.dish, qty: l.qty, notes: l.notes))
                    .toList();

                await ref.read(ordersV2RepositoryProvider).createOrderWithItems(
                      table: table,
                      lines: lines,
                    );

                ref.read(cartProvider.notifier).clear();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pedido enviado a cocina ✅')),
                  );
                }
              },
        label: const Text('Enviar a cocina'),
        icon: const Icon(Icons.send),
      ),
    );
  }
}

class _CartBar extends ConsumerWidget {
  const _CartBar({required this.cart});

  final List<CartLine> cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalItems = cart.fold<int>(0, (acc, l) => acc + l.qty);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text('Carrito: $totalItems'),
          const Spacer(),
          TextButton(
            onPressed: cart.isEmpty ? null : () => ref.read(cartProvider.notifier).clear(),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}