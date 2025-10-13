class TransactionModel {
  final int id;
  final DateTime tanggal;
  final String nama;
  final String jenis;
  final String kategori;
  final int total;

  TransactionModel({
    required this.id,
    required this.tanggal,
    required this.nama,
    required this.jenis,
    required this.kategori,
    required this.total,
  });

  // Factory constructor untuk membuat objek TransactionModel dari JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['ID'],
      // Parsing tanggal dari format string ISO 8601
      tanggal: DateTime.parse(json['Tanggal']),
      nama: json['Nama'],
      jenis: json['Jenis'],
      kategori: json['Kategori'],
      total: json['Total'],
    );
  }
}
