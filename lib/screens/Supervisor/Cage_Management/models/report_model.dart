class Report {
  final int id;
  final String pencatat;
  final String tanggal;
  final String jam;
  final double bobot;
  final int mati;
  final int pakan;
  final int solar;
  final int sekam;
  final int obat;

  Report({
    required this.id,
    required this.pencatat,
    required this.tanggal,
    required this.jam,
    required this.bobot,
    required this.mati,
    required this.pakan,
    required this.solar,
    required this.sekam,
    required this.obat,
  });

  // Helper konversi aman
  static int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
  static double _toDouble(dynamic v) => v is double ? v : double.tryParse(v?.toString() ?? '0.0') ?? 0.0;

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: _toInt(json['id']),
      pencatat: json['pencatat']?.toString() ?? 'N/A',
      tanggal: json['tanggal']?.toString() ?? '',
      jam: json['jam']?.toString() ?? '',
      bobot: _toDouble(json['bobot']),
      mati: _toInt(json['mati']),
      pakan: _toInt(json['pakan']),
      solar: _toInt(json['solar']),
      sekam: _toInt(json['sekam']),
      obat: _toInt(json['obat']),
    );
  }
}
