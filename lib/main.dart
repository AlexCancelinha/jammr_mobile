import 'package:flutter/material.dart';
import 'screens/scan/scan_screen.dart';

void main() {
  runApp(const JammrApp());
}

class JammrApp extends StatelessWidget {
  const JammrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jammr',
      theme: ThemeData.dark(useMaterial3: true),
      home: const ScanScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}