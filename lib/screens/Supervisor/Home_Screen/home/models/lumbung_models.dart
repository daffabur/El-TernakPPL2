class LumbungItem {
  final String name;
  final String unit;
  final double quantity;
  final double capacity;

  LumbungItem({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.capacity,
  });

  double get percentage => capacity == 0 ? 0 : (quantity / capacity) * 100;

  factory LumbungItem.fromJson(Map<String, dynamic> j) => LumbungItem(
    name: j['name'] as String,
    unit: j['unit'] as String,
    quantity: (j['quantity'] as num).toDouble(),
    capacity: (j['capacity'] as num).toDouble(),
  );
}
