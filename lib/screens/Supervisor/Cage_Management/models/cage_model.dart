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

  // Helper konversi aman -> int
  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;

  factory Cage.fromJson(Map<String, dynamic> j) {
    // id: id/kandang_id/ID/Id/id_kandang
    final id = _toInt(
      j['id'] ?? j['kandang_id'] ?? j['id_kandang'] ?? j['ID'] ?? j['Id'],
    );

    // name: name/nama/nama_kandang/Nama
    final name =
        (j['name'] ?? j['nama'] ?? j['nama_kandang'] ?? j['Nama'] ?? '')
            .toString();

    // capacity: capacity/kapasitas/Kapasitas
    final capacity = _toInt(j['capacity'] ?? j['kapasitas'] ?? j['Kapasitas']);

    // population:
    // BE bisa pakai berbagai nama
    final population = _toInt(
      j['population'] ??
          j['populasi'] ??
          j['jumlah_populasi'] ??
          j['Populasi'] ??
          j['JumlahAyam'] ??
          j['jumlah_ayam'] ?? // tambahan
          j['total_ayam'] ?? // tambahan
          j['current_population'], // tambahan
    );

    // deaths: deaths/kematian/Kematian
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

    // status: status/Status/aktif(boolean -> Aktif/Nonaktif)
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

    // notes: notes/catatan/Catatan
    final notes = (j['notes'] ?? j['catatan'] ?? j['Catatan'])?.toString();

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
  };
}
