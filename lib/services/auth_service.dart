import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';
  // --- TAMBAHKAN KEY BARU ---
  static const String _usernameKey = 'auth_username';

  String? _token;
  String? _role;
  // --- TAMBAHKAN STATE BARU ---
  String? _username;

  bool get isAuth => _token != null && _token!.isNotEmpty;
  String? get role => _role;
  // --- TAMBAHKAN GETTER BARU ---
  String? get username => _username;


  Future<String?> getToken() async {
    if (_token != null) return _token;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      _token = token;
      return token;
    } catch (e) {
      print("[AuthService] ❌ Failed to get token: $e");
      return null;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final role = prefs.getString(_roleKey);
    // --- TAMBAHKAN LOAD USERNAME ---
    final username = prefs.getString(_usernameKey);

    if (token == null || role == null || username == null) {
      return false; // Gagal jika salah satu tidak ada
    }

    _token = token;
    _role = role;
    // --- TAMBAHKAN SET USERNAME ---
    _username = username;

    notifyListeners();
    return true;
  }

  // --- REVISI FUNGSI LOGIN ---
  // Menerima 'username' sebagai parameter
  Future<void> login(String token, String role, String username) async {
    if (token.isEmpty || role.isEmpty || username.isEmpty) return;
    try {
      _token = token;
      _role = role;
      _username = username; // <-- Simpan di state

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_roleKey, role);
      await prefs.setString(_usernameKey, username); // <-- Simpan ke storage

      print("[AuthService] ✅ Token & User saved successfully.");
      notifyListeners();
    } catch (e) {
      print("[AuthService] ❌ Failed to save token: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _username = null; // <-- Hapus dari state

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_usernameKey); // <-- Hapus dari storage

    notifyListeners();
  }
}