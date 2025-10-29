// lib/screens/Supervisor/Cage_Management/models/cage_model.dart
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';

class Cage {
  final int id;
  final String name;
  final int capacity;
  final int population;
  final int deaths;
  final User? pic;
  final String status;
  final String? notes;
  final int pakan;
  final int solar;
  final int sekam;
  final int obat;

  // ===== tambahan: ringkasan konsumsi dari BE =====
  final num? pakan; // kg
  final num? solar; // L
  final num? sekam; // kg
  final num? obat; // L

  Cage({
    required this.id,
    required this.name,
    required this.capacity,
    required this.population,
    required this.deaths,
    this.pic,
    required this.status,
    this.notes,
    required this.pakan,
    required this.solar,
    required this.sekam,
    required this.obat,
  });

  // Helpers
  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
  static num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  factory Cage.fromJson(Map<String, dynamic> j) {
    // id: id/kandang_id/ID/Id/id_kandang
    final id = _toInt(
      j['id'] ?? j['kandang_id'] ?? j['id_kandang'] ?? j['ID'] ?? j['Id'],
    );

    // name: name/nama/nama_kandang/Nama
    final name =
        (j['name'] ?? j['nama'] ?? j['nama_kandang'] ?? j['Nama'] ?? '')
            .toString();

    // capacity
    final capacity = _toInt(j['capacity'] ?? j['kapasitas'] ?? j['Kapasitas']);

    // population
    final population = _toInt(
      j['population'] ??
          j['populasi'] ??
          j['jumlah_populasi'] ??
          j['Populasi'] ??
          j['JumlahAyam'] ??
          j['jumlah_ayam'] ??
          j['total_ayam'] ??
          j['current_population'],
    );

    // deaths
    final deaths = _toInt(j['deaths'] ?? j['kematian'] ?? j['Kematian']);

    // pic: pic/penanggung_jawab/pj/PIC/PenanggungJawab
    User? picObject;
    // Cari data pic dari berbagai kemungkinan key
    final picData = j['pic'] ??
        j['penanggung_jawab'] ??
        j['pj'] ??
        j['PIC'] ??
        j['PenanggungJawab'];

    // Jika data pic ditemukan dan merupakan sebuah Map, buat objek User darinya
    if (picData is Map<String, dynamic>) {
      picObject = User.fromJson(picData);
    }

    // status
    final status =
        (j['status'] ??
                j['Status'] ??
                (j['aktif'] == true
                    ? 'Aktif'
                    : j['aktif'] == false
                    ? 'Nonaktif'
                    : null))
            ?.toString() ??
        'Aktif';

    // notes
    final notes = (j['notes'] ?? j['catatan'] ?? j['Catatan'])?.toString();

    // ===== map empat field tambahan persis dari BE =====
    final pakan = _toNum(j['pakan']);
    final solar = _toNum(j['solar']);
    final sekam = _toNum(j['sekam']);
    final obat = _toNum(j['obat']);

    return Cage(
      id: id,
      name: name,
      capacity: capacity,
      population: population,
      deaths: deaths,
      pic: picObject,
      status: status,
      notes: notes,
      pakan: _toInt(j['pakan']),
      solar: _toInt(j['solar']),
      sekam: _toInt(j['sekam']),
      obat: _toInt(j['obat']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'capacity': capacity,
    'population': population,
    'deaths': deaths,
    'pic': pic,
    'status': status,
    'notes': notes,
    if (pakan != null) 'pakan': pakan,
    if (solar != null) 'solar': solar,
    if (sekam != null) 'sekam': sekam,
    if (obat != null) 'obat': obat,
  };

  @override
  String toString() =>
      'Cage(id:$id name:$name cap:$capacity pop:$population deaths:$deaths '
      'pakan:$pakan solar:$solar sekam:$sekam obat:$obat status:$status)';
}
