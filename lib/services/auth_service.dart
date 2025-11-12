import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan & mengambil token autentikasi.
/// Menggunakan SharedPreferences agar token tetap tersimpan
/// meskipun aplikasi ditutup.
class AuthService {
  static const String _tokenKey = 'auth_token';

  /// Simpan token setelah login berhasil.
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print("[AuthService] ✅ Token saved successfully.");
    } catch (e) {
      print("[AuthService] ❌ Failed to save token: $e");
      rethrow;
    }
  }

  /// Ambil token saat ini.
  /// Kalau tidak ada → return `null`.
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print(
        "[AuthService] 🔑 Retrieved token: ${token != null ? 'Found' : 'Not Found'}",
      );
      return token;
    } catch (e) {
      print("[AuthService] ❌ Failed to get token: $e");
      return null;
    }
  }

  /// Hapus token → biasanya dipanggil saat logout.
  Future<void> deleteToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print("[AuthService] 🗑️ Token deleted (logout).");
    } catch (e) {
      print("[AuthService] ❌ Failed to delete token: $e");
      rethrow;
    }
  }

  /// Cek apakah user sudah login (ada token).
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
