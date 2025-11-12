import 'dart:convert';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReportService {
  final String _baseUrl = 'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api';
  final _auth = AuthService();
  Future<Map<String, String>> _getHeaders() async {
    final token = await _auth.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token', // Sesuaikan jika format token berbeda
    };
  }
  Future<List<Report>> getByCageId(int cageId, {DateTime? date}) async {
    final token = await _auth.getToken();
    if (token == null) throw Exception('Token not found');

    final queryParams = <String, String>{
      'kandang': cageId.toString(),
    };

    if (date != null) {
      queryParams['periode'] = 'per_hari';
      queryParams['tanggal'] = DateFormat('yyyy-MM-dd').format(date);
    }

    final uri = Uri.parse('$_baseUrl/laporan').replace(queryParameters: queryParams);
    print("Memanggil API Laporan: $uri");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // --- PERBAIKAN PENTING DI SINI ---
      // Ambil 'data' sebagai dynamic terlebih dahulu
      final dynamic data = body['data'];

      // Cek apakah 'data' adalah List SEBELUM digunakan
      if (data is List) {
        // Jika ini adalah List (meskipun kosong), proses seperti biasa
        return data.map((item) => Report.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Jika 'data' adalah null atau BUKAN List,
        // kembalikan list kosong. JANGAN CRASH.
        return [];
      }
      // --- AKHIR PERBAIKAN ---

    } else {
      // (Error handling untuk status non-200)
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Gagal mengambil data laporan';
      if (response.statusCode == 404) {
        return [];
      }
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }
  Future<Report> getReportById(int reportId) async {
    final token = await _auth.getToken();
    if (token == null) {
      throw Exception('Autentikasi Gagal: Token tidak ditemukan');
    }


    final uri = Uri.parse('$_baseUrl/laporan/$reportId');

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
      final Map<String, dynamic> data = body['data'];
      return Report.fromJson(data);
    } else {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Gagal mengambil detail laporan';
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }
  Future<void> updateReport(int reportId, Map<String, dynamic> data) async {

    final payload = {
      "rata_bobot_ayam": data['rata_bobot_ayam'],
      "kematian_ayam": data['kematian_ayam'],
      "pakan_used": data['pakan_used'],
      "solar_used": data['solar_used'],
      "sekam_used": data['sekam_used'],
      "obat_used": data['obat_used'],
    };

    final response = await http.patch(
      Uri.parse('$_baseUrl/laporan/$reportId'),
      headers: await _getHeaders(),
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Sukses
      print('Laporan dengan ID $reportId berhasil diperbarui.');
      return;
    } else {
      // Gagal
      final errorBody = jsonDecode(response.body);
      final errorMessage = errorBody['message'] ?? 'Gagal memperbarui laporan.';
      throw Exception('Error ${response.statusCode}: $errorMessage');
    }
  }
}