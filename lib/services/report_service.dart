import 'dart:convert';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:http/http.dart' as http;

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
  Future<List<Report>> getByCageId(int cageId) async {
    final token = await _auth.getToken();
    if (token == null) throw Exception('Token not found');

    final uri = Uri.parse('$_baseUrl/laporan?kandang=$cageId');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Decode body JSON
      final body = jsonDecode(response.body);

      // Ambil list 'data' dari body JSON
      final List<dynamic> data = body['data'];

      // Ubah setiap item di list JSON menjadi objek Report menggunakan Report.fromJson
      // dan kembalikan sebagai List<Report>
      return data.map((item) => Report.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      // Jika server tidak merespons dengan status 200 OK, lempar error
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Gagal mengambil data laporan';
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }
  Future<Report> getReportById(int reportId) async {
    final token = await _auth.getToken();
    if (token == null) {
      throw Exception('Autentikasi Gagal: Token tidak ditemukan');
    }

    // Endpoint untuk detail: /laporan/{id}
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
      // Data detail adalah satu objek, bukan list
      final Map<String, dynamic> data = body['data'];
      return Report.fromJson(data);
    } else {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Gagal mengambil detail laporan';
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }
  Future<void> updateReport(int reportId, Map<String, dynamic> data) async {
    // Siapkan payload sesuai format yang diminta backend
    final payload = {
      // Gunakan null-aware operator untuk keamanan
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