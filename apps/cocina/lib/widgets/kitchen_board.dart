import 'package:flutter/material.dart';
import 'package:kds_shared/kds_shared.dart';

import '../kitchen_constants.dart';
import 'horizontal_board_scroll.dart';
import 'kitchen_column.dart';

class KitchenBoard extends StatelessWidget {
  const KitchenBoard({super.key, required this.items});

  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    final columnsWithItems = kitchenBoardColumns
        .map(
          (column) => (
            title: column.title,
            items: items.where((i) => i.status == column.status).toList(),
          ),
        )
        .toList(growable: false);

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
          constraints: const BoxConstraints(maxWidth: kitchenBoardMaxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final requiredWidth =
                  (kitchenBoardMinColumnWidth * kitchenBoardColumns.length) +
                  (kitchenBoardSpacing * (kitchenBoardColumns.length - 1)) +
                  24;
              final bottomInset = MediaQuery.of(context).padding.bottom;

              final boardRow = Row(
                children: [
                  for (var i = 0; i < columnsWithItems.length; i++) ...[
                    Expanded(
                      child: KitchenColumn(
                        title: columnsWithItems[i].title,
                        items: columnsWithItems[i].items,
                      ),
                    ),
                    if (i < columnsWithItems.length - 1)
                      const SizedBox(width: kitchenBoardSpacing),
                  ],
                ],
              );

              if (constraints.maxWidth < requiredWidth) {
                return HorizontalBoardScroll(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 10 + bottomInset),
                  child: SizedBox(width: requiredWidth, child: boardRow),
                );
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 10 + bottomInset),
                child: boardRow,
              );
            },
          ),
        ),
      ),
    );
  }
}
