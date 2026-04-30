import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cart.dart';
import '../providers.dart';

class CartSheet extends ConsumerWidget {
  const CartSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final table = ref.watch(selectedTableProvider);
    final cartMap = ref.watch(cartByTableProvider);

    final cart = table == null ? <CartLine>[] : (cartMap[table] ?? <CartLine>[]);
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
                        : () => ref.read(cartByTableProvider.notifier).clearTable(table),
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
                            subtitle:
                                line.notes.isEmpty ? null : Text('Notas: ${line.notes}'),
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
                                      : () => ref.read(cartByTableProvider.notifier).add(
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
                                      : () => _openLineNotes(context, ref, table, line),
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
                                .map((l) => (dish: l.dish, qty: l.qty, notes: l.notes))
                                .toList();

                            await ref
                                .read(ordersV2RepositoryProvider)
                                .createOrderWithItems(table: table, lines: lines);

                            ref.read(cartByTableProvider.notifier).clearTable(table);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pedido enviado a cocina')),
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                      onPressed: () => Navigator.pop(context, controller.text.trim()),
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
