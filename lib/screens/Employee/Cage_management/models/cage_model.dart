// lib/screens/Supervisor/Cage_Management/models/cage_model.dart
class Cage {
  final int? id;                 // nullable
  final String name;
  final int capacity;
  final int population;
  final int deaths;
  final String? pic;
  final String status;
  final String? notes;

  // ===== tambahan untuk ringkasan konsumsi =====
  final num? pakan;
  final num? solar;
  final num? sekam;
  final num? obat;

  const Cage({
    required this.id,
    required this.name,
    required this.capacity,
    required this.population,
    required this.deaths,
    required this.pic,
    required this.status,
    required this.notes,
    this.pakan,
    this.solar,
    this.sekam,
    this.obat,
  });

  // helpers
  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  static String _toStr(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  factory Cage.fromJson(Map<String, dynamic> j) {
    return Cage(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}'),
      name: _toStr(j['nama'] ?? j['name'] ?? j['Nama']),
      capacity: _toInt(j['kapasitas'] ?? j['capacity']),
      population: _toInt(j['populasi'] ?? j['population']),
      deaths: _toInt(j['kematian'] ?? j['deaths']),
      pic: (j['pic'] ?? j['foto'] ?? j['image'] ?? j['gambar'])?.toString(),
      status: _toStr(j['status'] ?? j['status_kandang'] ?? 'active'),
      notes: (j['catatan'] ?? j['notes'] ?? j['keterangan'])?.toString(),

      // map nilai ringkasan dari BE (GET /kandang/:id)
      pakan: _toNum(j['pakan']),
      solar: _toNum(j['solar']),
      sekam: _toNum(j['sekam']),
      obat: _toNum(j['obat']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nama': name,
        'kapasitas': capacity,
        'populasi': population,
        'kematian': deaths,
        'status': status,
        if (pic != null) 'pic': pic,
        if (notes != null) 'catatan': notes,
        if (pakan != null) 'pakan': pakan,
        if (solar != null) 'solar': solar,
        if (sekam != null) 'sekam': sekam,
        if (obat != null) 'obat': obat,
      };

  @override
  String toString() =>
      'Cage(id:$id name:$name cap:$capacity pop:$population deaths:$deaths pakan:$pakan solar:$solar sekam:$sekam obat:$obat status:$status)';
}
