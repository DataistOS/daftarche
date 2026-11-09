// lib/main.dart
import 'package:flutter/material.dart';
import 'package:daftarche/services/contact_service.dart';

void main() {
  runApp(const DaftarcheApp());
}

class DaftarcheApp extends StatelessWidget {
  const DaftarcheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دفترچه مخاطبین (Daftarche)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ContactsScreen(),
    );
  }
}
