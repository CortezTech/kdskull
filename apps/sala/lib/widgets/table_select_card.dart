import 'package:flutter/material.dart';

import 'table_progress_utils.dart';

class TableSelectCard extends StatelessWidget {
  const TableSelectCard({
    super.key,
    required this.tableNumber,
    required this.isOpen,
    required this.readyQty,
    required this.totalQty,
    required this.onTap,
  });

  final String tableNumber;
  final bool isOpen;
  final int readyQty;
  final int totalQty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final readyColor = readyChipColor(
      readyCount: readyQty,
      totalCount: totalQty,
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E6BA8).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.table_restaurant_rounded,
                      color: Color(0xFF0E6BA8),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Abierta',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (totalQty > 0) ...[
                        if (isOpen) const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: readyColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$readyQty/$totalQty listo${totalQty == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: readyColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Mesa $tableNumber',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2233),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalQty > 0
                    ? (readyQty >= totalQty
                          ? 'Todo listo para entregar'
                          : 'Faltan platos por salir')
                    : isOpen
                    ? 'Mesa abierta en servicio'
                    : 'Toca para abrir',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF5E6E89),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
