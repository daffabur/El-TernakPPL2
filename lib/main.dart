import 'package:flutter/material.dart';
import 'package:el_ternak_ppl2/login.dart';

void main() {
  runApp(const ElTernakApp());
}

class ElTernakApp extends StatelessWidget {
  const ElTernakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Ternak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false, primaryColor: const Color(0xFFFF7A00)),
      home: const LoginPage(),
    );
  }
}


