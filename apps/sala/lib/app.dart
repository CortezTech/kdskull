import 'package:flutter/material.dart';
import 'package:kds_sala/table_select_page.dart';
class SalaApp extends StatelessWidget {
  const SalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0E6BA8),
      onPrimary: Colors.white,
      secondary: Color(0xFFF18F01),
      onSecondary: Color(0xFF1F1300),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: Color(0xFFF5F7FB),
      onSurface: Color(0xFF1A2233),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KDS - Sala',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEFF3FA),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1A2233),
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2233),
            letterSpacing: 0.2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFDCE3EF)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      home: const TableSelectPage(),
    );
  }
}
