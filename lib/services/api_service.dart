import 'package:http/http.dart' as http;
import 'dart:convert'; // Diperlukan untuk jsonDecode
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';

class ApiService {

  static const String _baseUrl = 'http://10.0.2.2:11222/api/';
  final String _manualToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTkzMDU1MDYsImlkIjozLCJyb2xlIjoicGV0aW5nZ2kiLCJ1c2VybmFtZSI6ImphbWFsIn0._uzVAXzqHPU3d4tElQKUv21EdAWeOo8N3Tdppr9vTFk";

  Map<String, String> _getAuthHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_manualToken',
    };
  }
  Future<List<User>> getAllUsers() async {
    try {

      final response = await http.get(
        Uri.parse('${_baseUrl}manage/'),
        headers: _getAuthHeaders() ,
      );

      if (response.statusCode == 200) {
        final apiResponse = apiResponseFromJson(response.body);
        if (apiResponse.success) {
          return apiResponse.data;
        } else {
          throw Exception('Failed to load users: ${apiResponse.message}');
        }
      } else {
        throw Exception('Failed to load users. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}manage/create'),
        headers: _getAuthHeaders(), // Gunakan header otorisasi yang sama
        body: jsonEncode(userData),   // Kirim data user sebagai body request
      );

      // Cek jika request tidak berhasil (bukan 201 Created atau 200 OK)
      if (response.statusCode != 201 && response.statusCode != 200) {
        // Coba decode body response untuk mendapatkan pesan error dari server
        String errorMessage = 'Gagal membuat user. Status code: ${response.statusCode}';
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody.containsKey('message')) {
            errorMessage = 'Error: ${responseBody['message']}';
          }
        } catch (_) {
          // Jika body bukan JSON, gunakan pesan default
          errorMessage += ' | Response: ${response.body}';
        }
        throw Exception(errorMessage);
      }

      // Jika berhasil, tidak perlu mengembalikan apa-apa (void)
      // Kita bisa print untuk debugging
      print('User berhasil dibuat: ${response.body}');

    } catch (e) {
      // Lempar kembali error agar bisa ditangkap di UI
      throw Exception('Gagal terhubung ke server saat membuat user: $e');
    }
  }
  Future<void> updateUser(String originalUsername, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put( // Umumnya menggunakan PUT atau PATCH untuk update
        Uri.parse('${_baseUrl}manage/edit'), // URL sesuai yang Anda berikan
        headers: _getAuthHeaders(),
        body: jsonEncode(updateData),
      );

      if (response.statusCode != 200) {
        // Handle error response
        String errorMessage = 'Gagal memperbarui user. Status code: ${response.statusCode}';
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody.containsKey('message')) {
            errorMessage = 'Error: ${responseBody['message']}';
          }
        } catch (_) {
          errorMessage += ' | Response: ${response.body}';
        }
        throw Exception(errorMessage);
      }

      print('User "$originalUsername" berhasil diperbarui: ${response.body}');
    } catch (e) {
      throw Exception('Gagal terhubung ke server saat memperbarui user: $e');
    }
  }

  Future<void> deleteUser(String username) async {
    // 1. Endpoint yang benar (tanpa /username di path)
    final url = Uri.parse('${_baseUrl}manage/delete');

    // 2. Body JSON yang berisi username
    final body = jsonEncode(<String, String>{
      'username': username,
    });

    print('DELETE Request to: $url');
    print('With body: $body');

    // 3. Gunakan http.delete dengan body
    //    Paket http standar tidak memiliki http.delete dengan body.
    //    Kita harus membuat request secara manual.
    final request = http.Request('DELETE', url);
    request.headers.addAll(_getAuthHeaders()); // Gunakan header otorisasi Anda
    request.body = body;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus. Status: ${response.statusCode}, Body: ${response.body}');
    }

    print('User "$username" berhasil dihapus.');
  }

// Anda bisa menambahkan fungsi lain di sini (addUser, updateUser, deleteUser)
}
