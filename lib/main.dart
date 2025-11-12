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
      // Gunakan AuthWrapper sebagai home
      home: const AuthWrapper(),
    );
  }
}

/// Widget baru ini bertugas menangani logika "booting" aplikasi.
/// Ia akan mencoba auto-login SATU KALI, lalu menampilkan UI yang sesuai.
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
    // Ambil AuthService (listen: false aman di initState)
    final authService = Provider.of<AuthService>(context, listen: false);

    // Coba auto-login, tidak peduli berhasil atau tidak,
    // kita hentikan loading setelah selesai.
    try {
      await authService.tryAutoLogin();
    } catch (e) {
      // Tangani error jika ada
      print("Error during auto-login: $e");
    }

    // Set _isLoading ke false setelah selesai
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Selama proses pengecekan auto-login, tampilkan loading
    if (_isLoading) {
      return const SplashScreen();
    }

    // 2. Setelah selesai, gunakan Consumer untuk mendengarkan perubahan state
    //    Ini adalah logika Consumer Anda yang lama, tapi tanpa FutureBuilder.
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        // Log untuk debugging (bisa dihapus nanti)
        print("[AuthWrapper] Rebuilding: isAuth=${auth.isAuth}, role=${auth.role}");

        // 3. Jika pengguna sudah login
        if (auth.isAuth) {
          if (auth.role == 'pegawai') {
            return const BottomNavBarPeg();
          } else {
            return const BottomNavBar();
          }
        }

        // 4. Jika pengguna TIDAK login
        return const LoginPage();
      },
    );
  }
}

/// Widget sederhana untuk menampilkan loading indicator.
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

