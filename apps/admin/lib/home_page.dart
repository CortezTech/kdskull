import 'package:flutter/material.dart';
import 'stations_page.dart';
import 'dishes_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StationsPage()),
                );
              },
              child: const Text('Gestionar estaciones'),
            ),
            const SizedBox(height: 12),
            FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DishesPage()),
              );
            },
            child: const Text('Gestionar platos'),
            ),
          ],
        ),
      ),
    );
  }
}