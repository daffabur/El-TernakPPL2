// lib/services/storage_service.dart

import 'dart:convert';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_model.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart'; // Asumsi ini service autentikasi Anda
import 'package:http/http.dart' as http;

class StorageService {
  // Ganti dengan base URL API Anda
  final String _baseUrl = 'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api';
  final _auth = AuthService();

  // Fungsi untuk mengambil data stok
  Future<Storage> getStorageData() async {
    final token = await _auth.getToken();
    if (token == null) {
      throw Exception('Autentikasi Gagal: Token tidak ditemukan');
    }

    final uri = Uri.parse('$_baseUrl/storage/');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Ambil objek 'data' dari body JSON
      final Map<String, dynamic> data = body['data'];

      // Ubah objek JSON menjadi objek Storage menggunakan Storage.fromJson
      return Storage.fromJson(data);
    } else {
      // Jika server tidak merespons dengan status 200 OK, lempar error
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Gagal mengambil data stok';
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }

}
