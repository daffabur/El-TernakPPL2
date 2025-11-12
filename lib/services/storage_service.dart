// lib/services/storage_service.dart

import 'dart:convert';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_model.dart';
// --- TAMBAHKAN IMPORT MODEL BARU ---
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_detail.dart';
// ---
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:http/http.dart' as http;

class StorageService {
  final String _baseUrl = 'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api';
  final _auth = AuthService();

  // Helper untuk token (bisa disesuaikan jika sudah ada)
  Future<Map<String, String>> _getHeaders() async {
    final token = await _auth.getToken();
    if (token == null) {
      throw Exception('Autentikasi Gagal: Token tidak ditemukan');
    }
    return {
      'Authorization': token,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // --- FUNGSI LAMA (getStorageData) TETAP DI SINI ---
  Future<Storage> getStorageData() async {
    final uri = Uri.parse('$_baseUrl/storage/');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];
      return Storage.fromJson(data);
    } else {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Gagal mengambil data stok';
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }

  // --- FUNGSI BARU 1: Mengambil Detail Pakan ---
  Future<List<StorageItem>> getPakanDetails() async {
    final uri = Uri.parse('$_baseUrl/pakan');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> dataList = body['data'];

      // Ubah setiap item JSON menjadi StorageItem
      return dataList.map((json) {
        return StorageItem.fromJson(
          json,
          category: "Pakan",
          unit: "Kg", // Asumsi Pakan selalu Kg
        );
      }).toList();
    } else {
      throw Exception('Gagal memuat detail pakan');
    }
  }

  // --- FUNGSI BARU 2: Mengambil Detail OVK (Obat) ---
  Future<List<StorageItem>> getOvkDetails() async {
    final uri = Uri.parse('$_baseUrl/ovk');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> dataList = body['data'];

      // Ubah setiap item JSON menjadi StorageItem
      return dataList.map((json) {
        final String nama = json['nama'] ?? '';
        // Coba tebak unit dari nama
        String unit = "L"; // Default
        if (nama.contains(" G")) {
          unit = "G";
        } else if (nama.contains(" ML")) {
          unit = "ML";
        }

        return StorageItem.fromJson(
          json,
          category: "Obat",
          unit: unit,
        );
      }).toList();
    } else {
      throw Exception('Gagal memuat detail obat (OVK)');
    }
  }

// TODO: Nanti tambahkan fungsi untuk 'addStock'
}