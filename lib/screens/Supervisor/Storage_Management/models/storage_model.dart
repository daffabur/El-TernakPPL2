// lib/models/storage_model.dart

class Storage {
  final DateTime updatedAt;
  final int pakanStock;
  final int solarStock;
  final int sekamStock;
  final int obatStock;
  final int pakanUsed;
  final int solarUsed;
  final int sekamUsed;
  final int obatUsed;

  Storage({
    required this.updatedAt,
    required this.pakanStock,
    required this.solarStock,
    required this.sekamStock,
    required this.obatStock,
    required this.pakanUsed,
    required this.solarUsed,
    required this.sekamUsed,
    required this.obatUsed,
  });

  // Helper untuk parsing aman dari JSON. Mengembalikan 0 jika null atau tidak valid.
  static int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;

  // Helper untuk parsing tanggal. Mengembalikan tanggal saat ini jika null atau tidak valid.
  static DateTime _toDateTime(dynamic v) => v is String ? (DateTime.tryParse(v) ?? DateTime.now()) : DateTime.now();

  // Factory constructor untuk membuat objek Storage dari Map (data JSON)
  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      updatedAt: _toDateTime(json['updated_at']),
      pakanStock: _toInt(json['pakan_stock']),
      solarStock: _toInt(json['solar_stock']),
      sekamStock: _toInt(json['sekam_stock']),
      obatStock: _toInt(json['obat_stock']),
      pakanUsed: _toInt(json['pakan_used']),
      solarUsed: _toInt(json['solar_used']),
      sekamUsed: _toInt(json['sekam_used']),
      obatUsed: _toInt(json['obat_used']),
    );
  }
}
