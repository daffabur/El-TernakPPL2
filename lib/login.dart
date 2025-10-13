import 'dart:convert';
import 'package:el_ternak_ppl2/services/api_service.dart';   // <-- TAMBAHKAN
import 'package:el_ternak_ppl2/services/auth_service.dart'; // <-- TAMBAHKAN
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:el_ternak_ppl2/base/bottom_nav_bar.dart';
import 'package:el_ternak_ppl2/screens/Employee/Home_Screen/home_screen.dart';

enum UserRole { atasan, pegawai, unknown }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _isSubmitting = false;

  // === Buat Instance dari Service Anda ===
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  static const Color orange = Color(0xFFFF7A00);
  static const Color orangeSoft = Color(0xFFFFC766);

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // === FUNGSI LOGIN YANG DIPERBARUI ===
  Future<void> _doLogin() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Panggil fungsi login dari ApiService
      // Fungsi ini sudah menangani request dan parsing JSON dasar
      final token = await _apiService.login(
        _username.text.trim(),
        _password.text,
      );

      // 2. Simpan token menggunakan AuthService (SANGAT PENTING!)
      await _authService.saveToken(token);

      // 3. Decode token untuk mendapatkan role (jika role ada di dalam token)
      //    Ini adalah cara standar untuk mendapatkan info dari JWT tanpa perlu library tambahan.
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }
      final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );

      final roleStr = (payload['role'] ?? '').toString().toLowerCase().trim();
      final role = (roleStr == 'petinggi' || roleStr == 'atasan')
          ? UserRole.atasan
          : (roleStr == 'pegawai')
          ? UserRole.pegawai
          : UserRole.unknown;

      if (role == UserRole.unknown) {
        throw Exception('User role not found in token.');
      }

      if (!mounted) return;

      // 4. Navigasi berdasarkan role
      if (role == UserRole.pegawai) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else { // UserRole.atasan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavBar()),
        );
      }
    } catch (e) {
      _showSnack(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _roundedInput(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: orange),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: orange),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: orange, width: 2),
    ),
    errorBorder: OutlineInputBorder( // Tambahkan ini untuk konsistensi
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder( // Tambahkan ini untuk konsistensi
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset("assets/images/LogoElTernak.png", height: 100),
                const SizedBox(height: 12),

                // Username
                TextFormField(
                  controller: _username,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? "Username wajib diisi" : null,
                  textInputAction: TextInputAction.next,
                  decoration: _roundedInput("Username"),
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? "Password wajib diisi" : null,
                  onFieldSubmitted: (_) => _doLogin(),
                  decoration: _roundedInput("Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: orange,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      disabledBackgroundColor: orangeSoft.withOpacity(0.6),
                    ),
                    onPressed: _isSubmitting ? null : _doLogin,
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
