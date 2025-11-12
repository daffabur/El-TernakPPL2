// lib/services/storage_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_detail.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_report.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';

class StorageService {
  static const String _baseUrl =
      'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api';

  final AuthService _auth = AuthService();
  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 20);

  Uri _u(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Autentikasi gagal: token tidak ditemukan.');
    }
    final hasBearer = token.toLowerCase().startsWith('bearer ');
    final authHeader = hasBearer ? token : 'Bearer $token';

    return <String, String>{
      'Authorization': authHeader,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  T _handleResponse<T>({
    required http.Response resp,
    required T Function(dynamic json) onOk,
  }) {
    dynamic body;
    try {
      body = resp.body.isEmpty ? {} : jsonDecode(resp.body);
    } catch (_) {
      body = {'message': 'Response bukan JSON valid'};
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final payload = (body is Map && body.containsKey('data'))
          ? body['data']
          : body;
      return onOk(payload);
    }

    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Gagal (${resp.statusCode})';
    throw HttpException(msg);
  }

  /// === DIPAKAI UNTUK CARD "INFO LUMBUNG" ===
  /// Mapping langsung dari JSON /storage/ (tanpa mengandalkan model Storage),
  /// agar kompatibel dengan field BE: ovk_stock / ovk_used (Obat).
  Future<List<StorageItem>> getLumbungSummary() async {
    try {
      final resp = await _client
          .get(_u('/storage/'), headers: await _headers())
          .timeout(_timeout);

      return _handleResponse<List<StorageItem>>(
        resp: resp,
        onOk: (json) {
          final Map<String, dynamic> m = (json is Map<String, dynamic>)
              ? json
              : <String, dynamic>{};

          double _d(String k) {
            final v = m[k];
            if (v is num) return v.toDouble();
            if (v is String) return double.tryParse(v) ?? 0;
            return 0;
          }

          final pakanStock = _d('pakan_stock');
          final pakanUsed = _d('pakan_used');

          final sekamStock = _d('sekam_stock');
          final sekamUsed = _d('sekam_used');

          final solarStock = _d('solar_stock');
          final solarUsed = _d('solar_used');

          // Obat memakai OVK
          final ovkStock = _d('ovk_stock');
          final ovkUsed = _d('ovk_used');

          double cur(double stock, double used) =>
              (stock - used).clamp(0, stock);

          return <StorageItem>[
            StorageItem(
              id: 'pakan',
              name: 'Pakan',
              category: 'Pakan',
              unit: 'kg',
              totalStock: pakanStock,
              currentStock: cur(pakanStock, pakanUsed),
            ),
            StorageItem(
              id: 'sekam',
              name: 'Sekam',
              category: 'Sekam',
              unit: 'kg',
              totalStock: sekamStock,
              currentStock: cur(sekamStock, sekamUsed),
            ),
            StorageItem(
              id: 'obat',
              name: 'Obat',
              category: 'Obat',
              unit: 'L',
              totalStock: ovkStock, // <--- ovk_stock
              currentStock: cur(ovkStock, ovkUsed), // <--- ovk_used
            ),
            StorageItem(
              id: 'solar',
              name: 'Solar',
              category: 'Solar',
              unit: 'L',
              totalStock: solarStock,
              currentStock: cur(solarStock, solarUsed),
            ),
          ];
        },
      );
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw Exception('Timeout menghubungi server /storage/');
    }
  }

  /// Tetap disediakan untuk kompatibilitas kode lama yang memakai model Storage.
  Future<Storage> getStorageData() async {
    try {
      final resp = await _client
          .get(_u('/storage/'), headers: await _headers())
          .timeout(_timeout);

      return _handleResponse<Storage>(
        resp: resp,
        onOk: (json) {
          if (json is Map<String, dynamic>) {
            return Storage.fromJson(json);
          }
          throw const FormatException(
            'Format /storage/ tidak sesuai model Storage',
          );
        },
      );
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw Exception('Timeout menghubungi server /storage/');
    }
  }

  /// DETAIL PAKAN — mengembalikan list StorageItem (nama, stock, used -> current/total)
  Future<List<StorageItem>> getPakanDetails() async {
    try {
      final resp = await _client
          .get(_u('/pakan'), headers: await _headers())
          .timeout(_timeout);

      return _handleResponse<List<StorageItem>>(
        resp: resp,
        onOk: (json) {
          final List dataList = (json is Map && json['data'] is List)
              ? (json['data'] as List)
              : (json is List ? json : const []);

          return dataList.map<StorageItem>((e) {
            return StorageItem.fromJson(
              e as Map<String, dynamic>,
              category: 'Pakan',
              unit: 'kg',
            );
          }).toList();
        },
      );
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw Exception('Timeout menghubungi server /pakan');
    }
  }

  /// DETAIL OVK (Obat) — list item. Unit diambil heuristik dari nama (ml/g/L)
  Future<List<StorageItem>> getOvkDetails() async {
    try {
      final resp = await _client
          .get(_u('/ovk'), headers: await _headers())
          .timeout(_timeout);

      return _handleResponse<List<StorageItem>>(
        resp: resp,
        onOk: (json) {
          final List dataList = (json is Map && json['data'] is List)
              ? (json['data'] as List)
              : (json is List ? json : const []);

          return dataList.map<StorageItem>((e) {
            final map = e as Map<String, dynamic>;
            final nama = (map['nama'] ?? map['name'] ?? '')
                .toString()
                .toLowerCase();

            String unit = 'L';
            if (nama.contains(' ml') || nama.endsWith('ml')) unit = 'ml';
            if (nama.contains(' g') || nama.endsWith('g')) unit = 'g';

            return StorageItem.fromJson(map, category: 'Obat', unit: unit);
          }).toList();
        },
      );
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw Exception('Timeout menghubungi server /ovk');
    }
  }

  /// === Tambahan: Laporan Tahunan untuk chart konsumsi ===
  /// Endpoint: /storage/report?tahun=YYYY
  Future<StorageReport> getStorageYearlyReport(int year) async {
    try {
      final resp = await _client
          .get(_u('/storage/report?tahun=$year'), headers: await _headers())
          .timeout(_timeout);

      return _handleResponse<StorageReport>(
        resp: resp,
        onOk: (json) {
          // _handleResponse sudah meng-unwrap 'data' kalau ada.
          // Factory StorageReport mengharapkan bentuk {data: {...}}
          final payload = {'data': json};
          return StorageReport.fromJson(payload);
        },
      );
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet');
    } on TimeoutException {
      throw Exception('Timeout menghubungi server /storage/report');
    }
  }

  void dispose() {
    _client.close();
  }
}
