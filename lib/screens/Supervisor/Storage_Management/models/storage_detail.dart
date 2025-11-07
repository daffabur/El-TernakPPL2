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
}