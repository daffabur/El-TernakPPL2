// lib/screens/Supervisor/Cage_Management/models/report_model.dart

class Report {
  final int id;
  final String pencatat;
  final String tanggal;
  final String jam;
  final double bobot;
  final int mati;final int pakan;
  // Jika ada properti lain di masa depan, tambahkan di sini (misal: solar, sekam, obat)

  Report({
    required this.id,
    required this.pencatat,
    required this.tanggal,
    required this.jam,
    required this.bobot,
    required this.mati,
    required this.pakan,
  });

  // Helper untuk parsing aman dari JSON, mencegah error karena tipe data atau nilai null
  static int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
  static double _toDouble(dynamic v) => v is double ? v : double.tryParse(v?.toString() ?? '0.0') ?? 0.0;

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
    );
  }
}
