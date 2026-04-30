import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import '../kitchen_constants.dart';
import '../providers.dart';

class KitchenItemCard extends ConsumerWidget {
  const KitchenItemCard({super.key, required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(kitchenRepositoryProvider);
    final now = ref.watch(nowTickerProvider).valueOrNull ?? DateTime.now();

    final start = item.startedAt ?? item.createdAt;
    Duration? elapsed;
    if (start != null) {
      if (item.status == KitchenStatus.ready && item.readyAt != null) {
        elapsed = item.readyAt!.difference(start);
      } else {
        elapsed = now.difference(start);
      }
    }

    final std = Duration(
      seconds: item.stdPrepTimeSec <= 0 ? 1 : item.stdPrepTimeSec,
    );
    final slaText = elapsed == null
        ? '-'
        : '${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s / ${std.inMinutes}m';
    final late = elapsed != null && elapsed > std;

    String? next;
    String? label;
    if (item.status == KitchenStatus.todo) {
      next = KitchenStatus.inProgress;
      label = 'Empezar';
    } else if (item.status == KitchenStatus.inProgress) {
      next = KitchenStatus.ready;
      label = 'Listo';
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE1E7F3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Text(
                        item.dishName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (late)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFB3261E,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.priority_high_rounded,
                                size: 14,
                                color: Color(0xFFB3261E),
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Retraso',
                                style: TextStyle(
                                  color: Color(0xFFB3261E),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.qty}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Color(0xFF0E6BA8),
                    height: 1,
                  ),
                ),
              ],
            ),
            if (item.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Notas: ${item.notes}'),
            ],
            const SizedBox(height: 10),
            if (item.status == KitchenStatus.ready)
              Text(
                'Completado en $slaText',
                style: const TextStyle(color: Color(0xFF2E7D32)),
              )
            else
              Text(
                'Tiempo: $slaText',
                style: TextStyle(
                  color: late
                      ? const Color(0xFFB3261E)
                      : const Color(0xFF5E6E89),
                  fontWeight: late ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            const SizedBox(height: 10),
            if (label != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await repo.setItemStatus(
                        orderId: item.orderId,
                        itemId: item.id,
                        status: next!,
                      );
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No se pudo actualizar el estado. Intenta de nuevo.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
