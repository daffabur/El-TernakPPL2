import 'dart:convert';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ReportService {
  final String _baseUrl = 'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api';
  final _auth = AuthService();

  Future<List<Report>> getByCageId(int cageId) async {
    final token = await _auth.getToken();
    if (token == null) throw Exception('Token not found');

    final uri = Uri.parse('$_baseUrl/laporan/$cageId');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];

      if (data is List) {
        return data.map((item) => Report.fromJson(item as Map<String, dynamic>)).toList();
      } else if (data is Map<String, dynamic>) {
        return [Report.fromJson(data)];
      } else {
        return [];
      }
    } else {
      throw Exception('Gagal mengambil data laporan (Status: ${response.statusCode})');
    }
  }
}