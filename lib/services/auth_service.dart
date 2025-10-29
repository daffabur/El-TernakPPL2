import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthService with ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';

  String? _token;
  String? _role;

  bool get isAuth => _token != null && _token!.isNotEmpty;
  String? get role => _role;

  /// Ambil token saat ini.
  Future<String?> getToken() async {
    if (_token != null) return _token;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      _token = token;
      print(
        "[AuthService] 🔑 Retrieved token from storage: ${token != null ? 'Found' : 'Not Found'}",
      );
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

    if (token == null || role == null) {
      return false;
    }

    _token = token;
    _role = role;

    notifyListeners();
    return true;
  }

  Future<void> login(String token , String role) async {
    if (token.isEmpty || role.isEmpty) return;
    _role = role;
    try {
      _token = token;
      _role = role;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_roleKey, role);
      _token = token;
      print("[AuthService] ✅ Token saved successfully.");
      notifyListeners();
    } catch (e) {
      print("[AuthService] ❌ Failed to save token: $e");
      rethrow;
    }
  }

  /// Hapus token saat logout.
  Future<void> logout() async {
    _token = null;
    _role = null; // <-- Hapus role dari memori
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_roleKey);
      print("[AuthService] 🧹 Storage cleared on logout.");
    } catch (e) {
      print("[AuthService] ❌ Failed to clear storage on logout: $e");
    }


  }
}
