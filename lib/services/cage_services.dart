// lib/services/cage_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';

class CageService {
  // Base URL (port 80 + /api)
  static const String _base =
      'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api';

  // Set true untuk melihat log saat dev
  static const bool _debug = true;
  static const Duration _timeout = Duration(seconds: 20);

  final _auth = AuthService();

  // ================= Helpers =================

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    // Di AuthService kamu sudah simpan "Bearer xxx", jadi jangan didobel
    final authValue = token;

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': authValue,
    };
  }

  Uri _u(String p, [Map<String, dynamic>? q]) {
    final base = _base.endsWith('/')
        ? _base.substring(0, _base.length - 1)
        : _base;
    final path = p.startsWith('/') ? p : '/$p';
    final uri = Uri.parse('$base$path');
    return (q == null || q.isEmpty)
        ? uri
        : uri.replace(
            queryParameters: {
              ...uri.queryParameters,
              ...q.map((k, v) => MapEntry(k, '$v')),
            },
          );
  }

  dynamic _safeDecode(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }

  void _log(String msg) {
    if (_debug) print('[CageService] $msg');
  }

  Never _throwHttp(String where, http.Response r) {
    final body = r.body.isEmpty ? '<empty>' : r.body;
    throw Exception('[$where] HTTP ${r.statusCode} $body');
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  List<Cage> _parseList(dynamic body) {
    if (body == null) return const <Cage>[];
    final data = (body is Map<String, dynamic>) ? body['data'] : body;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => Cage.fromJson(e))
          .toList();
    }
    return const <Cage>[];
  }

  Cage _parseDetail(dynamic body) {
    if (body == null) {
      throw Exception('Respon kosong dari server.');
    }
    final data = (body is Map<String, dynamic>) ? body['data'] : null;
    if (data is Map<String, dynamic>) return Cage.fromJson(data);
    throw Exception('Format detail kandang tidak dikenali.');
  }

  // ================= READ =================

  /// Admin/Supervisor – ambil semua kandang
  Future<List<Cage>> getAll() async {
    final r = await http
        .get(_u('kandang/'), headers: await _headers())
        .timeout(_timeout);
    _log('GET /kandang/ -> ${r.statusCode}');
    if (r.statusCode != 200) {
      _throwHttp('GET /kandang/', r);
    }
    return _parseList(_safeDecode(r.body));
  }

  Future<List<Cage>> getForEmployee() async {
    try {
      final prof = await http
          .get(_u('account/me'), headers: await _headers())
          .timeout(_timeout);
      _log('GET /account/me -> ${prof.statusCode}');
      if (prof.statusCode != 200) {
        _throwHttp('GET /account/me', prof);
      }

      final body = _safeDecode(prof.body);
      final data = (body is Map<String, dynamic>) ? body['data'] : null;
      final kandangIdDyn = (data is Map<String, dynamic>)
          ? data['kandang_id']
          : null;
      if (kandangIdDyn == null) {
        _log('Pegawai tidak memiliki kandang.');
        return const <Cage>[];
      }

      final kandangId = (kandangIdDyn is int)
          ? kandangIdDyn
          : int.tryParse(kandangIdDyn.toString()) ?? -1;
      if (kandangId <= 0) {
        _log('kandang_id tidak valid: $kandangIdDyn');
        return const <Cage>[];
      }

      // 2) Ambil detail kandang
      final r = await http
          .get(_u('kandang/$kandangId'), headers: await _headers())
          .timeout(_timeout);
      _log('GET /kandang/$kandangId -> ${r.statusCode}');
      if (r.statusCode != 200) {
        _throwHttp('GET /kandang/$kandangId', r);
      }

      final cage = _parseDetail(_safeDecode(r.body));
      return <Cage>[cage];
    } catch (e) {
      _log('Error getForEmployee: $e');
      return const <Cage>[]; // jangan lempar error ke UI pegawai
    }
  }

  /// Detail kandang by id
  Future<Cage> getById(int id) async {
    final r = await http
        .get(_u('kandang/$id'), headers: await _headers())
        .timeout(_timeout);
    _log('GET /kandang/$id -> ${r.statusCode}');
    if (r.statusCode != 200) {
      _throwHttp('GET /kandang/$id', r);
    }
    return _parseDetail(_safeDecode(r.body));
  }

  // ================= CREATE =================

  /// Body dibuat supaya mirip dengan contoh Postman:
  /// {
  ///   "nama": "Kandang Depok",
  ///   "kapasitas": 5000,
  ///   "populasi": 4500,
  ///   "kematian": 500,
  ///   "konsumsi_pakan": 20,
  ///   "solar": 15,
  ///   "sekam": 15,
  ///   "obat": 5,
  ///   "status": "inactive"
  /// }
  Future<Cage> create(Map<String, dynamic> ui) async {
    final body = <String, dynamic>{
      'nama': (ui['nama'] ?? ui['name'] ?? ui['Nama'])?.toString(),
      'kapasitas': _toInt(ui['kapasitas'] ?? ui['capacity']) ?? 0,
      'populasi': _toInt(ui['populasi'] ?? ui['population']) ?? 0,
      'kematian': _toInt(ui['kematian'] ?? ui['deaths']) ?? 0,
      'konsumsi_pakan':
          _toNum(ui['konsumsi_pakan'] ?? ui['feed'] ?? ui['konsumsiPakan']) ??
          0,
      'solar': _toNum(ui['solar']) ?? 0,
      'sekam': _toNum(ui['sekam']) ?? 0,
      'obat': _toNum(ui['obat']) ?? 0,
      'status': (ui['status'] ?? 'active').toString().toLowerCase(),
    };

    _log('POST /kandang/create body: ${jsonEncode(body)}');

    final r = await http
        .post(
          _u('kandang/create'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    _log('POST /kandang/create -> ${r.statusCode} ${r.body}');

    if (r.statusCode != 201 && r.statusCode != 200) {
      final m = (_safeDecode(r.body) as Map?)?['message']?.toString();
      throw Exception(m ?? 'Gagal membuat kandang (status ${r.statusCode}).');
    }

    final data = (_safeDecode(r.body) as Map?)?['data'];
    if (data is Map<String, dynamic>) return Cage.fromJson(data);

    // Fallback jika respons tidak mengandung data, buat objek Cage dari input
    return Cage(
      id: DateTime.now().millisecondsSinceEpoch,
      name: (body['nama'] as String?) ?? '',
      capacity: (body['kapasitas'] as int?) ?? 0,
      population: (body['populasi'] as int?) ?? 0,
      deaths: (body['kematian'] as int?) ?? 0,
      pic: null,
      team: const [],
      status: (body['status'] as String?) ?? 'active',
      notes: null,
      pakan: (body['konsumsi_pakan'] as num?) ?? 0,
      solar: (body['solar'] as num?) ?? 0,
      sekam: (body['sekam'] as num?) ?? 0,
      obat: (body['obat'] as num?) ?? 0,
    );
  }

  /// ================ CREATE DAILY REPORT (laporan) ================
  Future<void> createLaporan({
    required int kandangId,
    required int kematianAyam,
    num? rataBobotAyam,
    required num pakanUsed,
    required num solarUsed,
    required num sekamUsed,
    required num obatUsed,
    String? pakanTipe,
    String? obatTipe,
  }) async {
    // Ambil id user (created_by) dari /account/me
    final me = await http
        .get(_u('account/me'), headers: await _headers())
        .timeout(_timeout);
    _log('GET /account/me -> ${me.statusCode}');
    if (me.statusCode != 200) {
      _throwHttp('GET /account/me', me);
    }
    final meJson = _safeDecode(me.body);
    final meData = (meJson is Map<String, dynamic>) ? meJson['data'] : null;
    final createdBy = (meData is Map<String, dynamic>) ? meData['id'] : null;
    if (createdBy == null) {
      throw Exception('Profil tidak berisi id user (created_by).');
    }

    final payload = <String, dynamic>{
      "created_by": createdBy,
      "kandang_id": kandangId,
      "rata_bobot_ayam": rataBobotAyam ?? 0,
      "kematian_ayam": kematianAyam,
      "pakan_used": pakanUsed,
      "solar_used": solarUsed,
      "sekam_used": sekamUsed,
      "obat_used": obatUsed,
      "bobot": rataBobotAyam ?? 0,
      "mati": kematianAyam,
      "pakan": pakanUsed,
      "solar": solarUsed,
      "sekam": sekamUsed,
      "obat": obatUsed,
      "pakan_tipe": pakanTipe,
      "obat_tipe": obatTipe,
    };

    final r = await http
        .post(
          _u('laporan/create'),
          headers: await _headers(),
          body: jsonEncode(payload),
        )
        .timeout(_timeout);
    _log('POST /laporan/create -> ${r.statusCode} ${r.body}');

    if (r.statusCode != 201 && r.statusCode != 200) {
      final msg = (_safeDecode(r.body) as Map?)?['message']?.toString();
      throw Exception(msg ?? 'Gagal membuat laporan (status ${r.statusCode}).');
    }

    final parsed = _safeDecode(r.body);
    if (parsed is Map &&
        parsed.containsKey('success') &&
        parsed['success'] == false) {
      final msg = parsed['message']?.toString() ?? 'Gagal membuat laporan.';
      throw Exception(msg);
    }
  }

  // ================= UPDATE =================

  Future<void> updateById(int id, Map<String, dynamic> ui) async {
    // Map dari berbagai kemungkinan nama field UI ke field BE
    final body = <String, dynamic>{};

    final nama = ui['nama'] ?? ui['name'] ?? ui['Nama'];
    if (nama != null) body['nama'] = nama.toString();

    final kapasitas = _toInt(ui['kapasitas'] ?? ui['capacity']);
    if (kapasitas != null) body['kapasitas'] = kapasitas;

    final pop = _toInt(ui['populasi'] ?? ui['population']);
    if (pop != null) body['populasi'] = pop;

    final kematian = _toInt(ui['kematian'] ?? ui['deaths']);
    if (kematian != null) body['kematian'] = kematian;

    final konsumsi = _toNum(
      ui['konsumsi_pakan'] ?? ui['feed'] ?? ui['konsumsiPakan'] ?? ui['pakan'],
    );
    if (konsumsi != null) body['konsumsi_pakan'] = konsumsi;

    final solar = _toNum(ui['solar']);
    if (solar != null) body['solar'] = solar;

    final sekam = _toNum(ui['sekam']);
    if (sekam != null) body['sekam'] = sekam;

    final obat = _toNum(ui['obat']);
    if (obat != null) body['obat'] = obat;

    final status = ui['status'];
    if (status != null) body['status'] = status.toString().toLowerCase();

    _log('PATCH /kandang/$id body: ${jsonEncode(body)}');

    final r = await http
        .patch(
          _u('kandang/$id'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    _log('PATCH /kandang/$id -> ${r.statusCode} ${r.body}');

    if (r.statusCode != 200) {
      _throwHttp('PATCH /kandang/$id', r);
    }
  }

  // ================= DELETE =================

  Future<void> deleteById(int id) async {
    final r = await http
        .delete(_u('kandang/$id'), headers: await _headers())
        .timeout(_timeout);
    _log('DELETE /kandang/$id -> ${r.statusCode}');
    if (r.statusCode != 200 && r.statusCode != 204) {
      _throwHttp('DELETE /kandang/$id', r);
    }
  }

  // ================= EXTRA: Laporan =================

  /// Ambil daftar laporan untuk pegawai yang sedang login.
  /// GET /laporan/me
  Future<List<Laporan>> getLaporanForMe() async {
    final r = await http
        .get(_u('laporan/me'), headers: await _headers())
        .timeout(_timeout);

    _log('GET /laporan/me -> ${r.statusCode}');
    if (r.statusCode != 200) {
      _throwHttp('GET /laporan/me', r);
    }

    final map = _safeDecode(r.body);

    final list = (map is Map ? map['data'] : map) as List? ?? const [];

    return list
        .whereType<Map>()
        .map((e) => Laporan.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// Ambil daftar laporan untuk sebuah kandang.
  /// GET /laporan?kandang=<id>
  Future<List<Laporan>> getLaporanPerKandang(int kandangId) async {
    final r = await http
        .get(_u('laporan', {'kandang': kandangId}), headers: await _headers())
        .timeout(_timeout);

    _log('GET /laporan?kandang=$kandangId -> ${r.statusCode}');
    if (r.statusCode != 200) {
      _throwHttp('GET /laporan?kandang=$kandangId', r);
    }

    final map = _safeDecode(r.body);
    final list = (map is Map ? map['data'] : null) as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => Laporan.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// Ambil detail satu laporan.
  /// GET /laporan/<id>
  Future<Laporan> getLaporanById(int laporanId) async {
    final r = await http
        .get(_u('laporan/$laporanId'), headers: await _headers())
        .timeout(_timeout);

    _log('GET /laporan/$laporanId -> ${r.statusCode}');
    if (r.statusCode != 200) {
      _throwHttp('GET /laporan/$laporanId', r);
    }

    final map = _safeDecode(r.body);
    final data = (map is Map ? map['data'] : null);
    if (data is Map<String, dynamic>) {
      return Laporan.fromJson(data);
    }
    throw Exception('Format detail laporan tidak dikenali.');
  }

  /// Update laporan (opsional, bila BE sediakan).
  /// PATCH /laporan/<id>
  Future<void> updateLaporanById(
    int laporanId,
    Map<String, dynamic> patch,
  ) async {
    final r = await http
        .patch(
          _u('laporan/$laporanId'),
          headers: await _headers(),
          body: jsonEncode(patch),
        )
        .timeout(_timeout);

    _log('PATCH /laporan/$laporanId -> ${r.statusCode}');
    if (r.statusCode != 200) {
      _throwHttp('PATCH /laporan/$laporanId', r);
    }
  }

  /// Hapus laporan (opsional).
  /// DELETE /laporan/<id>
  Future<void> deleteLaporanById(int laporanId) async {
    final r = await http
        .delete(_u('laporan/$laporanId'), headers: await _headers())
        .timeout(_timeout);

    _log('DELETE /laporan/$laporanId -> ${r.statusCode}');
    if (r.statusCode != 200 && r.statusCode != 204) {
      _throwHttp('DELETE /laporan/$laporanId', r);
    }
  }
}

/// =======================
/// Model ringan: Laporan
/// =======================
class Laporan {
  final int id;
  final String? pencatat;

  /// tanggal 'YYYY-MM-DD'
  final String? tanggalIso;

  /// jam 'HH:mm'
  final String? jam;
  final num? bobot; // rata_bobot / bobot
  final int? mati;
  final num? pakan;
  final num? solar;
  final num? sekam;
  final num? obat;

  Laporan({
    required this.id,
    this.pencatat,
    this.tanggalIso,
    this.jam,
    this.bobot,
    this.mati,
    this.pakan,
    this.solar,
    this.sekam,
    this.obat,
  });

  factory Laporan.fromJson(Map<String, dynamic> json) {
    return Laporan(
      id: (json['id'] as int?) ?? int.tryParse('${json['id']}') ?? -1,
      pencatat: json['pencatat']?.toString(),
      tanggalIso: json['tanggal']?.toString(),
      jam: json['jam']?.toString(),
      bobot: _asNum(json['bobot']),
      mati: (json['mati'] is int)
          ? json['mati'] as int
          : int.tryParse('${json['mati']}'),
      pakan: _asNum(json['pakan']),
      solar: _asNum(json['solar']),
      sekam: _asNum(json['sekam']),
      obat: _asNum(json['obat']),
    );
  }

  static num? _asNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  String summary() {
    final b = (bobot != null) ? 'Bobot ${_trim(bobot)} kg' : null;
    final m = (mati != null) ? 'Mati: ${mati!}' : null;
    final p = (pakan != null) ? 'Pakan: ${_trim(pakan)} kg' : null;
    final parts = [
      b,
      m,
      p,
    ].where((e) => e != null && e!.isNotEmpty).cast<String>().toList();
    return parts.join(' | ');
  }

  String get tanggalForHuman => tanggalIso ?? '';

  static String _trim(num? n) {
    if (n == null) return '';
    final s = n.toString();
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
