class StorageItem {
  final String id;
  final String name;
  final double currentStock;
  final double totalStock;
  final String unit;
  final String category;

  StorageItem({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.totalStock,
    required this.unit,
    required this.category,
  });

  factory StorageItem.fromJson(
      Map<String, dynamic> json, {
        required String category,
        required String unit,
      }) {
    // Ambil data 'stock' dan 'used' dari JSON
    final double stock = (json['stock'] as num?)?.toDouble() ?? 0.0;
    final double used = (json['used'] as num?)?.toDouble() ?? 0.0;

    // Lakukan transformasi data
    final double currentStock = stock - used;
    final double totalStock = stock;
    final String name = json['nama'] ?? 'Tanpa Nama';

    return StorageItem(
      // Karena tidak ada ID, kita gunakan 'nama' sebagai ID unik
      id: name,
      name: name,
      currentStock: currentStock,
      totalStock: totalStock,
      unit: unit,
      category: category,
    );
  }
}