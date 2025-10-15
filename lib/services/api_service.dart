import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:11222/api/';
  final AuthService _authService = AuthService();

  // =========================================================
  // Helper untuk mendapatkan header otentikasi
  // =========================================================
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please log in again.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token, // sesuai pola GET lain di project-mu
    };
  }

  // =========================================================
  // AUTH: Login
  // =========================================================
  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final String? token = responseBody['data']?['token'];
      if (token != null && token.isNotEmpty) {
        // print('Login successful, token received.');
        return token;
      } else {
        throw Exception('Respons login tidak valid: token tidak ditemukan.');
      }
    } else {
      try {
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Username atau password salah.';
        throw Exception(errorMessage);
      } catch (_) {
        throw Exception('Gagal login. Status: ${response.statusCode}');
      }
    }
  }

  // =========================================================
  // MANAGE ACCOUNT: Get all users
  // GET /manage/
  // =========================================================
  Future<List<User>> getAllUsers() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${_baseUrl}manage/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final apiResponse = apiResponseFromJson(response.body);
        if (apiResponse.success) {
          return apiResponse.data;
        } else {
          throw Exception(apiResponse.message ?? 'Failed to load users');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi anda habis, tolong login kembali');
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // =========================================================
  // MANAGE ACCOUNT: Get pegawai only
  // GET /manage/pegawai
  // (dipakai utk dropdown Penanggung Jawab)
  // =========================================================
  Future<List<User>> getPegawaiOnly() async {
    try {
      final headers = await _getAuthHeaders();
      final res = await http.get(
        Uri.parse('${_baseUrl}manage/pegawai'),
        headers: headers,
      );

      if (res.statusCode != 200) {
        if (res.statusCode == 401) {
          throw Exception('Sesi anda habis, tolong login kembali');
        }
        throw Exception('Gagal memuat pegawai. Status: ${res.statusCode}');
      }

      final body = jsonDecode(res.body);
      final data = (body is Map<String, dynamic>) ? body['data'] : body;

      if (data is List) {
        // Pastikan mapping aman meskipun response hanya berisi sebagian field.
        return data
            .whereType<Map<String, dynamic>>()
            .map<User>((j) => User.fromJson(j))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Opsional: hanya pegawai aktif (kalau model User punya isActive/is_active)
  Future<List<User>> getActivePegawaiOnly() async {
    final list = await getPegawaiOnly();
    // Sesuaikan properti boolean aktif di model User kamu
    return list.where((u) {
      final v = (u.isActive ?? u.isActive ?? true);
      return v == true;
    }).toList();
  }

  // =========================================================
  // MANAGE ACCOUNT: Create user
  // POST /manage/create
  // =========================================================
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${_baseUrl}manage/create'),
        headers: headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        try {
          final responseBody = jsonDecode(response.body);
          final errorMessage = responseBody['message'] ?? 'Gagal membuat user.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Gagal membuat user. Status: ${response.statusCode}');
        }
      }
      // print('User berhasil dibuat: ${response.body}');
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // =========================================================
  // MANAGE ACCOUNT: Update user
  // PUT /manage/edit
  // =========================================================
  Future<void> updateUser(
    String originalUsername,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('${_baseUrl}manage/edit'),
        headers: headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode != 200) {
        try {
          final responseBody = jsonDecode(response.body);
          final errorMessage =
              responseBody['message'] ?? 'Gagal memperbarui user.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception(
            'Gagal memperbarui user. Status: ${response.statusCode}',
          );
        }
      }
      // print('User "$originalUsername" berhasil diperbarui: ${response.body}');
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // =========================================================
  // MANAGE ACCOUNT: Delete user
  // DELETE /manage/delete (body: { username })
  // =========================================================
  Future<void> deleteUser(String username) async {
    try {
      final url = Uri.parse('${_baseUrl}manage/delete');
      final body = jsonEncode({'username': username});

      final request = http.Request('DELETE', url);
      request.headers.addAll(await _getAuthHeaders());
      request.body = body;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        try {
          final responseBody = jsonDecode(response.body);
          final errorMessage =
              responseBody['message'] ?? 'Gagal menghapus user.';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Gagal menghapus. Status: ${response.statusCode}');
        }
      }
      // print('User "$username" berhasil dihapus.');
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }
}
