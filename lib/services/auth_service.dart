// D:/CODE/Kuliah/Demo_El-TernakPPL2/El-TernakPPL2/lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Kunci untuk menyimpan token di SharedPreferences
  static const String _tokenKey = 'auth_token';

  // Menyimpan token setelah login berhasil
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print("Token saved successfully.");
  }

  // Mengambil token dari penyimpanan
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print("Retrieved token: ${token != null ? 'Found' : 'Not Found'}");
    return token;
  }

  // Menghapus token saat logout
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print("Token deleted (logout).");
  }
}
