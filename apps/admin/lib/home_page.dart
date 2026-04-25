import 'package:flutter/material.dart';
import 'stations_page.dart';
import 'dishes_page.dart';

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
                _ActionCard(
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
                _ActionCard(
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2233),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF5E6E89),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
