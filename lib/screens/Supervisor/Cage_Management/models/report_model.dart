// lib/screens/Supervisor/Cage_Management/models/report_model.dart

class Report {
  final int id;
  final String pencatat;
  final String tanggal;
  final String jam;
  final double bobot;
  final int mati;final int pakan;
  final int? solar;
  final int? sekam;
  final int? obat;

  Report({
    required this.id,
    required this.pencatat,
    required this.tanggal,
    required this.jam,
    required this.bobot,
    required this.mati,
    required this.pakan,
    this.solar,
    this.sekam,
    this.obat,
  });

  // Helper untuk parsing aman dari JSON, mencegah error karena tipe data atau nilai null
  static int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
  static double _toDouble(dynamic v) => v is double ? v : double.tryParse(v?.toString() ?? '0.0') ?? 0.0;
  static int? _toNullableInt(dynamic v) => v == null ? null : _toInt(v);

  // Factory constructor untuk membuat objek Report dari Map (data JSON)
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: _toInt(json['id']),
      pencatat: json['pencatat']?.toString() ?? 'N/A', // Beri nilai default jika null
      tanggal: json['tanggal']?.toString() ?? '',
      jam: json['jam']?.toString() ?? '',
      bobot: _toDouble(json['bobot']),
      mati: _toInt(json['mati']),
      pakan: _toInt(json['pakan']),
      solar: _toNullableInt(json['solar']),
      sekam: _toNullableInt(json['sekam']),
      obat: _toNullableInt(json['obat']),
    );
  }
}
