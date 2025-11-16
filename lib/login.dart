import 'dart:convert';
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/base/widgets/app_dialogs.dart';
import 'package:el_ternak_ppl2/screens/Employee/bottom_nav_bar_peg.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:el_ternak_ppl2/base/bottom_nav_bar.dart';
import 'package:el_ternak_ppl2/screens/Employee/bottom_nav_bar_peg.dart';



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

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  // --- (Fungsi _decodeJwtPayload dan _mapRoleFromPayload tidak diubah) ---
  // Map<String, dynamic> _decodeJwtPayload(String token) {
  //   try {
  //     final parts = token.split('.');
  //     if (parts.length != 3) throw const FormatException('Invalid token');
  //     final normalized = base64Url.normalize(parts[1]);
  //     final payloadStr = utf8.decode(base64Url.decode(normalized));
  //     final jsonMap = json.decode(payloadStr);
  //     return (jsonMap is Map<String, dynamic>) ? jsonMap : <String, dynamic>{};
  //   } catch (_) {
  //     return <String, dynamic>{};
  //   }
  // }

  // UserRole _mapRoleFromPayload(Map<String, dynamic> payload) {
  //   String raw = '';
  //   if (payload['role'] != null)
  //     raw = payload['role'].toString();
  //   else if (payload['Role'] != null)
  //     raw = payload['Role'].toString();
  //   else if (payload['roles'] is List &&
  //       (payload['roles'] as List).isNotEmpty) {
  //     raw = (payload['roles'] as List).first.toString();
  //   } else if (payload['data'] is Map &&
  //       (payload['data'] as Map)['role'] != null) {
  //     raw = (payload['data'] as Map)['role'].toString();
  //   }
  //   final r = raw.toLowerCase().trim();
  //   if (r == 'pegawai' || r == 'employee' || r == 'karyawan') {
  //     return UserRole.pegawai;
  //   }
  //   if (r == 'petinggi' || r == 'atasan' || r == 'supervisor' || r == 'admin') {
  //     return UserRole.atasan;
  //   }
  //   return UserRole.unknown;
  // }
  // ---

  // === LOGIN ===
  Future<void> _doLogin() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 1) Panggil fungsi login 2-langkah dari ApiService
      final Map<String, String> loginData = await _apiService.login(
        _username.text.trim(),
        _password.text,
      );

      final String token = loginData['token']!;
      final String role = loginData['role']!;
      final String username = loginData['username']!;

      // 2) Simpan SEMUA data ke AuthService
      if (mounted) {
        await Provider.of<AuthService>(context, listen: false)
            .login(token, role, username);
      }

      // 3) --- KEMBALIKAN NAVIGASI MANUAL ---
      // Ini adalah cara "brute force" untuk memastikan state lama
      // (dari logout sebelumnya) hancur total.
      if (!mounted) return;

      if (role == 'pegawai') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavBarPeg()),
        );
      } else { // Asumsi 'petinggi' atau role lain
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavBar()),
        );
      }
      // --- AKHIR REVISI ---

    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      await AppDialogs.showError(context, title: 'Login Gagal', message: errorMessage);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _roundedInput(String label) => InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.poppins(color: AppStyles.highlightColor),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: AppStyles.highlightColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: AppStyles.highlightColor, width: 2),
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
                        color: AppStyles.highlightColor,
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
                      backgroundColor: AppStyles.highlightColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      disabledBackgroundColor:
                      AppStyles.highlightColor.withOpacity(0.6),
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
                        : Text(
                      "Login",
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 16),
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
