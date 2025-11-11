class LumbungItem {
  final String nama;
  final double jumlah;
  final double total;
  final String satuan;
  final int warna;

  LumbungItem({
    required this.nama,
    required this.jumlah,
    required this.total,
    required this.satuan,
    required this.warna,
  });

  double get persentase => (jumlah / total) * 100;
}
