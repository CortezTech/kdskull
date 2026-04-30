import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'providers.dart';
import 'home_page.dart';
import 'widgets/table_select_card.dart';

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
                          return TableSelectCard(
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
