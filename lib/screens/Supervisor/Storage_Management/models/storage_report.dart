// lib/screens/Supervisor/Storage_Management/models/storage_report.dart

class StorageReport {
  final String tahun;
  final Map<String, num> pakan;
  final Map<String, num> solar;
  final Map<String, num> sekam;
  final Map<String, num> ovk;

  StorageReport({
    required this.tahun,
    required this.pakan,
    required this.solar,
    required this.sekam,
    required this.ovk,
  });

  /// Urutan bulan yang dipakai UI (Jan..Des)
  static const months = [
    'januari','februari','maret','april','mei','juni',
    'juli','agustus','september','oktober','november','desember'
  ];

  /// Helper: pastikan map bernilai num, default 0 kalau null/invalid
  static Map<String, num> _numMap(Map<String, dynamic>? src) {
    final m = <String, num>{};
    if (src == null) return m;
    for (final e in src.entries) {
      final v = e.value;
      if (v is num) {
        m[e.key] = v;
      } else if (v is String) {
        m[e.key] = num.tryParse(v) ?? 0;
      } else {
        m[e.key] = 0;
      }
    }
    return m;
  }

  factory StorageReport.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return StorageReport(
      tahun: (data['tahun'] ?? '').toString(),
      pakan: _numMap((data['pakan'] as Map?)?.cast<String, dynamic>()),
      solar: _numMap((data['solar'] as Map?)?.cast<String, dynamic>()),
      sekam: _numMap((data['sekam'] as Map?)?.cast<String, dynamic>()),
      ovk:   _numMap((data['ovk']   as Map?)?.cast<String, dynamic>()),
    );
  }

  /// Ambil deret 12 angka sesuai urutan bulan tetap
  List<num> series(Map<String, num> m) =>
      months.map((b) => m[b] ?? 0).toList(growable: false);
}
