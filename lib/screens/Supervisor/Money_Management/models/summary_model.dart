class SummaryModel {
  final int totalPengeluaran;
  final int totalPemasukan;
  final int saldo;

  SummaryModel({
    required this.totalPengeluaran,
    required this.totalPemasukan,
    required this.saldo,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      totalPengeluaran: json['Total_pengeluaran'] ?? 0,
      totalPemasukan: json['Total_pemasukan'] ?? 0,
      saldo: json['Saldo'] ?? 0,
    );
  }
}
