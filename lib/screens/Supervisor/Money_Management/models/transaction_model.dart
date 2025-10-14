import 'dart:convert';

T? _parse<T>(dynamic value) {
  if (value == null) return null;
  if (T == double) return double.tryParse(value.toString()) as T?;
  if (T == int) return int.tryParse(value.toString()) as T?;
  return value as T?;
}

class TransactionModel {
  final int id;
  final DateTime tanggal;
  final String nama;
  final String jenis;
  final String kategori;
  final double total;

  final String? catatan;
  final String? bukti;

  TransactionModel({
    required this.id,
    required this.tanggal,
    required this.nama,
    required this.jenis,
    required this.kategori,
    required this.total,
    this.catatan,
    this.bukti,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    if (json['ID'] == null ||
        json['Tanggal'] == null ||
        json['Total'] == null) {
      throw FormatException(
        "JSON tidak valid: ID, Tanggal, atau Total tidak boleh null.",
      );
    }

    return TransactionModel(
      id: json['ID'],
      tanggal: DateTime.parse(json['Tanggal'] as String),
      nama: json['Nama'] ?? 'Tanpa Nama',
      jenis: json['Jenis'] ?? 'lainnya',
      kategori: json['Kategori'] ?? 'Lainnya',
      total: double.tryParse(json['Total'].toString()) ?? 0.0,
      catatan: json['Catatan'],
      bukti: json['Bukti'],
    );
  }
}
