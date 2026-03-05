import 'package:flutter/material.dart';
import 'package:kds_sala/table_select_page.dart';
import 'home_page.dart';

class SalaApp extends StatelessWidget {
  const SalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KDS - Sala',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TableSelectPage(),
    );
  }
}
