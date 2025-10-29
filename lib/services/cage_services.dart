// lib/services/cage_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';

class CageService {
  static const String _base = 'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api';
  static const bool _debug = false;

  final _auth = AuthService();

  // ================= Helpers =================
  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    final bearer = token.startsWith('Bearer ') ? token : 'Bearer $token';
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': bearer,
    };
  }

  int _toInt(dynamic v, {int fallback = 0}) =>
      v is int ? v : (int.tryParse('${v ?? ''}') ?? fallback);

  Uri _u(String p) => Uri.parse('$_base$p');

  dynamic _safeDecode(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }

  List<Cage> _parseList(dynamic body) {
    final data = (body is Map<String, dynamic>) ? body['data'] : body;
    if (data is List) {
      return data.map((e) => Cage.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <Cage>[];
  }

  Cage _parseDetail(dynamic body) {
    final data = (body is Map<String, dynamic>) ? body['data'] : null;
    if (data is Map<String, dynamic>) return Cage.fromJson(data);
    throw Exception('Format detail kandang tidak dikenali.');
  }

  // ================ Paths (perlu persis!) ================
  static const _listAdminA = '/kandang/'; // dengan trailing slash
  static const _listAdminB = '/kandang'; // tanpa trailing slash

  static const _create = '/kandang/create';
  String _detail(int id) => '/kandang/$id';
  String _deleteAlt(int id) => '/kandang/delete/$id';

  Future<List<Cage>> getAll() async {
    // coba A
    var r = await http.get(_u(_listAdminA), headers: await _headers());
    if (_debug) print('[CAGE LIST ADMIN A] ${r.statusCode}');
    // fallback B kalau 404/301/308 (path mismatch) atau 500 aneh
    if (r.statusCode != 200) {
      r = await http.get(_u(_listAdminB), headers: await _headers());
      if (_debug) print('[CAGE LIST ADMIN B] ${r.statusCode}');
    }
    if (r.statusCode != 200) {
      throw Exception('Gagal memuat kandang (status ${r.statusCode}).');
    }
    return _parseList(_safeDecode(r.body));
  }

  Future<List<Cage>> getForEmployee() async {
    final rawToken = await _auth.getToken();
    if (rawToken == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    final bearer = rawToken.startsWith('Bearer ')
        ? rawToken
        : 'Bearer $rawToken';

    final candidates = <String>[
      '/kandang/pegawai',
      '/kandang/pegawai/', // kalau BE pakai trailing slash
      '/kandang/mine',
      '/kandang/mine/',
      '/kandang/user',
      '/kandang/user/',
      '/kandang/', // fallback: list umum dengan trailing slash
      '/kandang', // fallback: tanpa trailing slash
    ];

    Future<http.Response> _hit(String path, String auth) {
      if (_debug) {
        print(
          '[EMP LIST] hit $path with ${auth.startsWith("Bearer ") ? "Bearer" : "raw"}',
        );
      }
      return http.get(
        _u(path),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': auth,
        },
      );
    }

    http.Response? last;
    for (final path in candidates) {
      // 1) Bearer
      var r = await _hit(path, bearer);
      last = r;
      if (r.statusCode == 200) return _parseList(_safeDecode(r.body));

      // 2) Raw (hanya kalau unauthorized/forbidden)
      if (r.statusCode == 401 || r.statusCode == 403) {
        r = await _hit(path, rawToken);
        last = r;
        if (r.statusCode == 200) return _parseList(_safeDecode(r.body));
      }
      // lanjut ke kandidat berikutnya jika 404 / 5xx dll
    }

    throw Exception('Gagal memuat kandang (status ${last?.statusCode}).');
  }

  Future<Cage> getById(int id) async {
    final r = await http.get(_u(_detail(id)), headers: await _headers());
    if (_debug) print('[CAGE DETAIL] ${r.statusCode}');
    if (r.statusCode != 200) {
      throw Exception('Gagal memuat detail kandang (status ${r.statusCode}).');
    }
    return _parseDetail(_safeDecode(r.body));
  }

  // ================= CREATE =================
// lib/services/cage_services.dart

  // ================= CREATE (SUDAH DIPERBAIKI) =================
  Future<Cage> create(Map<String, dynamic> ui) async {
    int? idPj;
    final dynamic idPenanggungJawabValue = ui['idPenanggungJawab'];
    if (idPenanggungJawabValue is List && idPenanggungJawabValue.isNotEmpty) {
      idPj = _toInt(idPenanggungJawabValue.first);
    } else if (idPenanggungJawabValue is int) {
      idPj = idPenanggungJawabValue;
    } else {
      idPj = _toInt(idPenanggungJawabValue);
    }
    idPj ??= _toInt(ui['id_pj_kandang']);

    if (idPj == null || idPj == 0) {
      final dynamic picData = ui['pic'];
      if (picData != null) {
        try {
          // Coba akses properti 'id' jika 'picData' adalah objek (misal: User)
          idPj = _toInt((picData as dynamic).id);
        } catch (_) {
          // Jika gagal (mis. 'picData' adalah Map), coba akses sebagai Map
          if (picData is Map) {
            idPj = _toInt(picData['id']);
          }
        }
      }
    } // <-- KURUNG PENUTUP YANG HILANG DITAMBAHKAN DI SINI

    // --- BLOK KODE INI DIPINDAHKAN KE LUAR DARI 'IF' ---
    // Siapkan body untuk dikirim ke API
    final body = <String, dynamic>{
      'nama': (ui['nama'] ?? ui['name'] ?? ui['Nama'])?.toString(),
      'kapasitas': _toInt(ui['kapasitas'] ?? ui['capacity']),

      // Kirim ke backend jika idPj valid (bukan null dan bukan 0)
      if (idPj != null && idPj != 0) 'idPenanggungJawab': idPj,

      if (ui['status'] != null) 'status': ui['status'].toString().toLowerCase(),
    };

    final r = await http.post(
      _u(_create),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (_debug) print('[CAGE CREATE] ${r.statusCode} ${r.body}');

    if (r.statusCode != 201 && r.statusCode != 200) {
      final m = (_safeDecode(r.body) as Map?)?['message']?.toString();
      throw Exception(m ?? 'Gagal membuat kandang (status ${r.statusCode}).');
    }

    final data = (_safeDecode(r.body) as Map?)?['data'];
    if (data is Map<String, dynamic>) return Cage.fromJson(data);

    // Fallback jika respons tidak mengandung data, buat objek Cage dari input
    return Cage(
      id: DateTime.now().millisecondsSinceEpoch, // ID sementara
      name: (body['nama'] as String?) ?? '',
      capacity: body['kapasitas'] as int? ?? 0,
      population: 0,
      deaths: 0,
      pic: null,
      status: (ui['status']?.toString() ?? 'active'),
      notes: null,
    );
    // --- AKHIR BLOK YANG DIPINDAHKAN ---
  }


  // ================= UPDATE =================
  Future<void> updateById(int id, Map<String, dynamic> ui) async {
    final nama = (ui['nama'] ?? ui['name'] ?? ui['Nama'])?.toString();
    final kapasitas = _toInt(ui['kapasitas'] ?? ui['capacity']);
    if (nama == null || nama.trim().isEmpty) {
      throw Exception('Nama tidak boleh kosong saat update.');
    }

    int? idPj = ui['id_pj_kandang'] as int?;
    idPj ??=
        (ui['idPenanggungJawab'] is List &&
            (ui['idPenanggungJawab'] as List).isNotEmpty)
        ? _toInt((ui['idPenanggungJawab'] as List).first)
        : null;

    final body = <String, dynamic>{
      'nama': nama,
      'kapasitas': kapasitas,
      'populasi': _toInt(ui['populasi'] ?? ui['population'], fallback: 0),
      'kematian': _toInt(ui['kematian'] ?? ui['deaths'], fallback: 0),
      'konsumsi_pakan': _toInt(ui['konsumsi_pakan'], fallback: 0),
      'solar': _toInt(ui['solar'], fallback: 0),
      'sekam': _toInt(ui['sekam'], fallback: 0),
      'obat': _toInt(ui['obat'], fallback: 0),
      if (ui['status'] != null) 'status': ui['status'].toString().toLowerCase(),
      if (idPj != null) 'id_pj_kandang': idPj,
    };

    if (_debug) print('[CAGE UPDATE BODY] $body');

    var r = await http.patch(
      _u(_detail(id)),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (_debug) print('[CAGE UPDATE PATCH] ${r.statusCode}');

    if (r.statusCode == 405 || r.statusCode == 404) {
      r = await http.put(
        _u(_detail(id)),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      if (_debug) print('[CAGE UPDATE PUT] ${r.statusCode}');
    }

    if (r.statusCode != 200) {
      final dec = _safeDecode(r.body);
      final msg = (dec is Map && dec['message'] != null)
          ? dec['message'].toString()
          : r.body.toString();
      throw Exception(
        'Gagal memperbarui kandang (status ${r.statusCode}): $msg',
      );
    }
  }

  // ================= DELETE =================
  Future<void> deleteById(int id) async {
    var r = await http.delete(_u(_detail(id)), headers: await _headers());
    if (r.statusCode == 200 || r.statusCode == 204) return;

    r = await http.delete(_u(_deleteAlt(id)), headers: await _headers());
    if (r.statusCode == 200 || r.statusCode == 204) return;

    final m = (_safeDecode(r.body) as Map?)?['message']?.toString();
    throw Exception(m ?? 'Gagal menghapus kandang (status ${r.statusCode}).');
  }
}
