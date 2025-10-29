import 'dart:convert';
import 'package:el_ternak_ppl2/screens/Employee/bottom_nav_bar_peg.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Navbar supervisor (atasan)
import 'package:el_ternak_ppl2/base/bottom_nav_bar.dart';

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

  final ApiService _apiService = ApiService();

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

  // --- Util aman untuk decode payload JWT ---
  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw const FormatException('Invalid token');
      final normalized = base64Url.normalize(parts[1]);
      final payloadStr = utf8.decode(base64Url.decode(normalized));
      final jsonMap = json.decode(payloadStr);
      return (jsonMap is Map<String, dynamic>) ? jsonMap : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  // --- Ambil role dari beberapa kemungkinan field ---
  UserRole _mapRoleFromPayload(Map<String, dynamic> payload) {
    String raw = '';

    // Coba beberapa lokasi/format umum
    if (payload['role'] != null)
      raw = payload['role'].toString();
    else if (payload['Role'] != null)
      raw = payload['Role'].toString();
    else if (payload['roles'] is List &&
        (payload['roles'] as List).isNotEmpty) {
      raw = (payload['roles'] as List).first.toString();
    } else if (payload['data'] is Map &&
        (payload['data'] as Map)['role'] != null) {
      raw = (payload['data'] as Map)['role'].toString();
    }

    final r = raw.toLowerCase().trim();

    // Sinkronkan sebutan
    if (r == 'pegawai' || r == 'employee' || r == 'karyawan') {
      return UserRole.pegawai;
    }
    if (r == 'petinggi' || r == 'atasan' || r == 'supervisor' || r == 'admin') {
      return UserRole.atasan;
    }
    return UserRole.unknown;
  }

  // === LOGIN ===
  Future<void> _doLogin() async {if (_isSubmitting) return;
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSubmitting = true);

  try {
    // 1) Minta token dari API
    final token = await _apiService.login(
      _username.text.trim(),
      _password.text,
    );

    // --- PERBAIKAN: Pindahkan Logika Role ke Atas ---
    // 2) Baca role dari payload JWT SEBELUM menyimpan
    final payload = _decodeJwtPayload(token);
    final role = _mapRoleFromPayload(payload);

    if (role == UserRole.unknown) {
      throw Exception('User role tidak ditemukan pada token.');
    }
    // --- AKHIR PERBAIKAN URUTAN ---


    // 3) Simpan token DAN role menggunakan Provider
    if (mounted) {
      // PERBAIKAN: Berikan kedua argumen yang dibutuhkan
      await Provider.of<AuthService>(context, listen: false).login(token, role.name);
    }

    // 4) Arahkan sesuai role (logika navigasi manual ini bisa Anda simpan atau hapus
    // jika Anda sudah percaya 100% pada Consumer di main.dart)
    if (!mounted) return;
    if (role == UserRole.pegawai) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavBarPeg()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavBar()),
      );
    }

  } catch (e) {
    _showSnack(e.toString().replaceAll('Exception: ', ''));
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
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
