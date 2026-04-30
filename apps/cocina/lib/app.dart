import 'package:flutter/material.dart';

import 'home_page.dart';
import 'theme.dart';

class CocinaApp extends StatelessWidget {
  const CocinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KDS - Cocina',
      theme: buildCocinaTheme(),
      home: const HomePage(),
    );
  }
}
