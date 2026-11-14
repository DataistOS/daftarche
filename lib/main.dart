// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:daftarche/screens/contacts_list_screen.dart';

void main() {
  runApp(const DaftarcheApp());
}

class DaftarcheApp extends StatelessWidget {
  const DaftarcheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دفترچه مخاطبین',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Vazirmatn',
      ),
      home: const ContactsListScreen(),
    );
  }
}
