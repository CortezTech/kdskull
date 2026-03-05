import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'home_page.dart';

class TableSelectPage extends ConsumerWidget {
  const TableSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = List.generate(6, (i) => '${i + 1}'); // 1..6

    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona mesa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: tables.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, i) {
            final t = tables[i];
            return FilledButton(
              onPressed: () {
                ref.read(selectedTableProvider.notifier).state = t;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              child: Text('Mesa $t', style: const TextStyle(fontSize: 18)),
            );
          },
        ),
      ),
    );
  }
}
