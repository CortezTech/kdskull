import 'package:flutter/material.dart';
import 'package:kds_shared/kds_shared.dart';

import 'kitchen_styles.dart';
import 'kitchen_table_section.dart';

class KitchenColumn extends StatelessWidget {
  const KitchenColumn({super.key, required this.title, required this.items});

  final String title;
  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort(sortByCreated);
    final groupedByTable = _groupItemsByTable(sorted);
    final accent = statusAccent(title);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: accent.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withValues(alpha: 0.32), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              border: Border(
                bottom: BorderSide(color: accent.withValues(alpha: 0.22)),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon(title), color: accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A2233),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: sorted.isEmpty
                ? const Center(child: Text('Vac\u00EDo'))
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      12,
                      12,
                      40 + MediaQuery.of(context).padding.bottom,
                    ),
                    itemCount: groupedByTable.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      final entry = groupedByTable.entries.elementAt(i);
                      return KitchenTableSection(
                        tableLabel: entry.key,
                        items: entry.value,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Map<String, List<OrderItem>> _groupItemsByTable(List<OrderItem> sortedItems) {
    final grouped = <String, List<OrderItem>>{};
    for (final item in sortedItems) {
      final tableKey = item.table;
      grouped.putIfAbsent(tableKey, () => <OrderItem>[]).add(item);
    }
    return grouped;
  }
}
