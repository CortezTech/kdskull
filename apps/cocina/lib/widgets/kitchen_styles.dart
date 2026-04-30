import 'package:flutter/material.dart';
import 'package:kds_shared/kds_shared.dart';

Color statusAccent(String title) {
  switch (title) {
    case 'Pendiente':
      return const Color(0xFFB3261E);
    case 'En marcha':
      return const Color(0xFFD97706);
    case 'Listo':
      return const Color(0xFF2E7D32);
    default:
      return const Color(0xFF0E6BA8);
  }
}

IconData statusIcon(String title) {
  switch (title) {
    case 'Pendiente':
      return Icons.schedule_rounded;
    case 'En marcha':
      return Icons.local_fire_department_rounded;
    case 'Listo':
      return Icons.task_alt_rounded;
    default:
      return Icons.kitchen_rounded;
  }
}

int sortByCreated(OrderItem a, OrderItem b) {
  final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  return da.compareTo(db);
}
