import 'package:flutter/material.dart';

class TopStatusActions extends StatelessWidget {
  const TopStatusActions({
    super.key,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isOpen ? const Color(0xFF2E7D32) : const Color(0xFF5E6E89))
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isOpen ? 'Mesa abierta' : 'Mesa nueva',
                style: TextStyle(
                  color: isOpen ? const Color(0xFF2E7D32) : const Color(0xFF5E6E89),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            if (totalCount > 0) ...[
              const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }
}
