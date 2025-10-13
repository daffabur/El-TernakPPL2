import 'package:flutter/material.dart';
import 'package:el_ternak_ppl2/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ElTernakApp());
}

class ElTernakApp extends StatelessWidget {
  const ElTernakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Ternak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: false,
          primaryColor: const Color(0xFFFF7A00),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme
          )
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Mendukung Bahasa Indonesia
      ],
      locale: const Locale('id', 'ID'),
      home: const LoginPage(),
    );
  }
}


