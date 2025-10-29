// lib/screens/Supervisor/Cage_Management/models/report_item_modal.dart

// 1. Hapus semua import UI (material.dart, google_fonts.dart)
// 2. Hapus 'extends StatelessWidget' dan seluruh build method.
// 3. Kelas ini sekarang menjadi model data murni.

class ReportItem {
  final DateTime date;
  final String details;

  ReportItem({
    required this.date,
    required this.details,
  });

  // Factory constructor untuk membuat objek ReportItem dari JSON
  factory ReportItem.fromJson(Map<String, dynamic> json) {
    // Ambil string tanggal dari JSON, pastikan tidak null
    final dateString = json['report_date']?.toString() ?? '';

    // Konversi string menjadi DateTime, berikan nilai default jika gagal
    final date = DateTime.tryParse(dateString) ?? DateTime.now();

    // Ambil detail, pastikan tidak null
    final details = json['details']?.toString() ?? 'Tidak ada detail';

    return ReportItem(
      date: date,
      details: details,
    );
  }
}
