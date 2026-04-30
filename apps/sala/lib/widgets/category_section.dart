import 'package:flutter/material.dart';
import 'package:kds_shared/kds_shared.dart';

import 'dish_row.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.category,
    required this.dishes,
  });

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
