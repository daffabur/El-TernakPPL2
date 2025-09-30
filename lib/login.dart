import 'package:flutter/material.dart';
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

  // Dummy users (sementara, nanti bisa ganti ke API)
  final Map<String, Map<String, dynamic>> _users = {
    'atasan': {'password': '123456', 'role': UserRole.atasan},
    'boss': {'password': 'admin', 'role': UserRole.atasan},
    'pegawai': {'password': '123456', 'role': UserRole.pegawai},
    'employee': {'password': 'user', 'role': UserRole.pegawai},
  };

  static const Color orange = Color(0xFFFF7A00);
  static const Color orangeSoft = Color(0xFFFFC766);

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _doLogin() {
    if (!_formKey.currentState!.validate()) return;

    final uname = _username.text.trim();
    final pass = _password.text;

    if (_users.containsKey(uname) && _users[uname]!['password'] == pass) {
      final UserRole role = _users[uname]!['role'] as UserRole;

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah')),
      );
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
                    ),
                    onPressed: _doLogin,
                    child: const Text(
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
