import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:el_ternak_ppl2/base/bottom_nav_bar.dart';
import 'package:el_ternak_ppl2/screens/Employee/Home_Screen/home_screen.dart';

enum UserRole { atasan, pegawai }

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

  // === Konfigurasi API ===
  // Android emulator: pakai 10.0.2.2 untuk mengakses localhost mesin host.
  // iOS Simulator: boleh tetap 'localhost'.
  String get _baseHost {
    if (kIsWeb) return 'localhost';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      default:
        return 'localhost';
    }
  }

  Uri get _loginUri => Uri.parse('http://$_baseHost:11222/api/auth/login');

  static const Color orange = Color(0xFFFF7A00);
  static const Color orangeSoft = Color(0xFFFFC766);

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _doLogin() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final body = jsonEncode({
        'username': _username.text.trim(),
        'password': _password.text,
      });

      final res = await http
          .post(
            _loginUri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        _showSnack('Server error (${res.statusCode})');
        setState(() => _isSubmitting = false);
        return;
      }

      final Map<String, dynamic> json = jsonDecode(res.body);

      // Expektasi respons (sesuai screenshot Postman):
      // {
      //   "success": true,
      //   "message": "Login Berhasil",
      //   "data": { "role": "petinggi" | "pegawai", "token": "..." }
      // }
      final success = json['success'] == true;
      if (!success) {
        _showSnack(json['message']?.toString() ?? 'Login gagal');
        setState(() => _isSubmitting = false);
        return;
      }

      final data = (json['data'] is Map)
          ? json['data'] as Map<String, dynamic>
          : {};
      final roleStr = (data['role'] ?? '').toString().toLowerCase().trim();
      // Map API -> enum
      final role = (roleStr == 'petinggi' || roleStr == 'atasan')
          ? UserRole.atasan
          : UserRole.pegawai;

      // NOTE: kalau mau simpan token:
      // final token = data['token']?.toString();
      // simpan pakai shared_preferences / secure storage sesuai kebutuhan

      if (!mounted) return;

      if (role == UserRole.pegawai) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavBar()),
        );
      }
    } catch (e) {
      _showSnack('Tidak dapat terhubung ke server: $e');
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
