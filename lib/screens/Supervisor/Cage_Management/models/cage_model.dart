import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';

class Cage {
  final int id;
  final String name;
  final int capacity;
  final int population;
  final int deaths;

  // --- PERUBAHAN HYBRID ---
  final User? pic;      // <-- TETAP DIPERTAHANKAN untuk kode lama
  final List<User> team; // <-- BARU DITAMBAHKAN untuk fitur dropdown
  // ---

  final String status;
  final String? notes;

  final num? pakan;
  final num? solar;
  final num? sekam;
  final num? obat;

  Cage({
    required this.id,
    required this.name,
    required this.capacity,
    required this.population,
    required this.deaths,
    this.pic, // <-- Dipertahankan
    required this.team, // <-- Ditambahkan
    required this.status,
    this.notes,
    this.pakan,
    this.solar,
    this.sekam,
    this.obat,
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
    // (Parsing id, name, capacity, population, deaths tidak berubah)
    final id = _toInt(
      j['id'] ?? j['kandang_id'] ?? j['id_kandang'] ?? j['ID'] ?? j['Id'],
    );
    final name =
    (j['name'] ?? j['nama'] ?? j['nama_kandang'] ?? j['Nama'] ?? '')
        .toString();
    final capacity = _toInt(j['capacity'] ?? j['kapasitas'] ?? j['Kapasitas']);
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
    final deaths = _toInt(j['deaths'] ?? j['kematian'] ?? j['Kematian']);

    // --- LOGIKA PARSING TEAM (PENANGGUNG JAWAB) BARU ---
    List<User> teamList = [];
    User? picObject;

    final pjData = j['penanggung_jawab'] ?? j['pic'] ?? j['pj'] ?? j['PIC'] ?? j['PenanggungJawab'];

    if (pjData is List) {
      // 1. Jika data adalah ARRAY (sesuai JSON baru Anda)
      teamList = pjData
          .map((userData) => User.fromJson(userData as Map<String, dynamic>))
          .toList();

      // Cari PJ dari daftar tim
      try {
        picObject = teamList.firstWhere((user) => user.isPj);
      } catch (e) {
        // Jika tidak ada PJ, ambil user pertama sebagai fallback
        picObject = teamList.isNotEmpty ? teamList.first : null;
      }

    } else if (pjData is Map<String, dynamic>) {
      // 2. Fallback jika API lama mengirim SATU OBJEK
      picObject = User.fromJson(pjData);
      teamList = [picObject]; // Tim hanya berisi satu orang (si PJ)
    }
    // --- AKHIR LOGIKA BARU ---

    // (Parsing status, notes, pakan, dll tidak berubah)
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
    final notes = (j['notes'] ?? j['catatan'] ?? j['Catatan'])?.toString();
    final pakan = _toNum(j['pakan']);
    final solar = _toNum(j['solar']);
    final sekam = _toNum(j['sekam']);
    final obat = _toNum(j['obat']);

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
      pic: picObject,   // <-- Variabel 'pic' lama tetap diisi
      team: teamList, // <-- Variabel 'team' baru juga diisi
      status: status,
      notes: notes,
      pakan: pakan,
      solar: solar,
      sekam: sekam,
      obat: obat,
    );
  }

  // Helper (opsional) untuk menemukan PJ dari daftar tim
  // (Sebaiknya gunakan ini daripada 'pic' di kode baru)
  User? get pj {
    try {
      return team.firstWhere((user) => user.isPj);
    } catch (e) {
      return team.isNotEmpty ? team.first : null;
    }
  }
}
