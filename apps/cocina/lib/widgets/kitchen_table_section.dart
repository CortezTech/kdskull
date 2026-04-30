import 'package:flutter/material.dart';
import 'package:kds_shared/kds_shared.dart';

import 'kitchen_item_card.dart';

class KitchenTableSection extends StatelessWidget {
  const KitchenTableSection({
    super.key,
    required this.tableLabel,
    required this.items,
    required this.totalDishCount,
    required this.stationCount,
    required this.otherDishCount,
    required this.otherStationsLabel,
  });

  final String tableLabel;
  final List<OrderItem> items;
  final int totalDishCount;
  final int stationCount;
  final int otherDishCount;
  final String otherStationsLabel;

  @override
  Widget build(BuildContext context) {
    final isMultiStation = stationCount > 1 && otherDishCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0E6BA8).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(
                'Mesa $tableLabel',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0E6BA8),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E6BA8).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$totalDishCount plato${totalDishCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Color(0xFF0E6BA8),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              if (isMultiStation) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2233).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$otherDishCount de $otherStationsLabel',
                    style: const TextStyle(
                      color: Color(0xFF1A2233),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < items.length; i++) ...[
          KitchenItemCard(item: items[i]),
          if (i < items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
