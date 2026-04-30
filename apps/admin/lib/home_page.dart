import 'package:flutter/material.dart';

import 'dishes_page.dart';
import 'stations_page.dart';
import 'widgets/home_action_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Administración')),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión rápida',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: Color(0xFF1A2233),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accede a las secciones principales para actualizar estaciones y platos.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4A5A75),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                HomeActionCard(
                  title: 'Gestionar estaciones',
                  subtitle: 'Crear, editar y ordenar estaciones de cocina.',
                  icon: Icons.grid_view_rounded,
                  accent: const Color(0xFF0E6BA8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StationsPage()),
                    );
                  },
                ),
                const SizedBox(height: 14),
                HomeActionCard(
                  title: 'Gestionar platos',
                  subtitle: 'Actualiza disponibilidad, categoría y tiempos.',
                  icon: Icons.restaurant_menu_rounded,
                  accent: const Color(0xFFF18F01),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DishesPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
