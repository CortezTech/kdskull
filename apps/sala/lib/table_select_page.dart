import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'providers.dart';
import 'home_page.dart';

class TableSelectPage extends ConsumerWidget {
  const TableSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = List.generate(6, (i) => '${i + 1}'); // 1..6
    final sessions =
        ref.watch(tableSessionsProvider).valueOrNull ??
        const <String, TableSessionState>{};
    final progressByTable =
        ref.watch(tableReadyProgressByTableProvider).valueOrNull ??
        const <String, TableReadyProgress>{};

    return Scaffold(
      appBar: AppBar(title: const Text('Panel Sala')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF3FB), Color(0xFFE7EEF9)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona mesa',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: Color(0xFF1A2233),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Elige una mesa para empezar a tomar el pedido.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4A5A75),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width >= 1000
                          ? 4
                          : width >= 700
                          ? 3
                          : 2;

                      return GridView.builder(
                        itemCount: tables.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.25,
                        ),
                        itemBuilder: (context, i) {
                          final t = tables[i];
                          final session = sessions[t];
                          final progress = progressByTable[t];
                          return _TableCard(
                            tableNumber: t,
                            isOpen: session?.isOpen ?? false,
                            readyQty: progress?.readyQty ?? (session?.doneOrders ?? 0),
                            totalQty: progress?.totalQty ?? (session?.doneOrders ?? 0),
                            onTap: () {
                              ref.read(selectedTableProvider.notifier).state =
                                  t;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
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
    final hasProgress = totalQty > 0;
    final allReady = hasProgress && readyQty >= totalQty;
    final noneReady = hasProgress && readyQty == 0;
    final readyChipColor = allReady
        ? const Color(0xFF2E7D32)
        : noneReady
        ? const Color(0xFFB3261E)
        : const Color(0xFFD97706);

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
                            color: const Color(0xFF2E7D32).withValues(
                              alpha: 0.14,
                            ),
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
                            color: readyChipColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$readyQty/$totalQty listo${totalQty == 1 ? '' : 's'}',
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
