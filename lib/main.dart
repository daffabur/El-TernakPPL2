// lib/main.dart

import 'package:el_ternak_ppl2/base/bottom_nav_bar.dart';
import 'package:el_ternak_ppl2/screens/Employee/bottom_nav_bar_peg.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:el_ternak_ppl2/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const ElTernakApp(),
    ),
  );
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
            Theme.of(context).textTheme,
          )),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
      ],
      locale: const Locale('id', 'ID'),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.tryAutoLogin();
    } catch (e) {
      print("Error during auto-login: $e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tampilkan loading screen saat cek auto-login
    if (_isLoading) {
      return const SplashScreen();
    }

    // 2. Gunakan Consumer untuk mendengarkan perubahan state
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        print("[AuthWrapper] Rebuilding: isAuth=${auth.isAuth}, role=${auth.role}");

        // 3. Jika pengguna SUDAH login
        if (auth.isAuth) {

          // --- PERBAIKAN LOGIKA DI SINI ---
          // Logika ini robust terhadap race condition.
          // Jika 'isAuth' benar, kita PASTI tunjukkan salah satu dashboard.

          if (auth.role == 'pegawai') {
            return const BottomNavBarPeg();
          } else {
            return const BottomNavBar();
          }
          // --- AKHIR PERBAIKAN ---
        }

        // 4. Jika pengguna TIDAK login (auth.isAuth == false)
        return const LoginPage();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}