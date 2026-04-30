import 'package:flutter/material.dart';
import 'table_select_page.dart';
import 'theme.dart';

class SalaApp extends StatelessWidget {
  const SalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KDS - Sala',
      theme: buildSalaTheme(),
      home: const TableSelectPage(),
    );
  }
}
