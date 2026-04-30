import 'package:flutter/material.dart';

Color readyChipColor({
  required int readyCount,
  required int totalCount,
}) {
  final hasProgress = totalCount > 0;
  final allReady = hasProgress && readyCount >= totalCount;
  final noneReady = hasProgress && readyCount == 0;

  if (allReady) return const Color(0xFF2E7D32);
  if (noneReady) return const Color(0xFFB3261E);
  return const Color(0xFFD97706);
}
