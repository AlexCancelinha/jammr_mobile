import 'package:flutter/material.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(const JammrApp());
}

class JammrApp extends StatelessWidget {
  const JammrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jammr',
      theme: ThemeData.dark(),
      home: const ScanScreen(),
    );
  }
}