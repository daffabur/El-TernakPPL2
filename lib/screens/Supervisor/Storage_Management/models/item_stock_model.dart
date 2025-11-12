class ItemStockModel {
  final String nama;
  final int stock;
  final int used;

  ItemStockModel({required this.nama, required this.stock, required this.used});

    factory ItemStockModel.fromJson(Map<String, dynamic> json) {
      return ItemStockModel(
      nama: json['nama'] ?? 'Tanpa Nama',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      used: (json['used'] as num?)?.toInt() ?? 0
      );
  }
}