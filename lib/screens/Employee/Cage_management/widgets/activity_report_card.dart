import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- IMPORT MODEL LAPORAN ---
// (Sesuaikan path ini jika model Laporan Anda ada di tempat lain)
import 'package:el_ternak_ppl2/services/cage_services.dart';

class ActivityReportCard extends StatelessWidget {
  // --- 1. KONSTRUKTOR BARU ---
  // Hanya menerima objek Laporan mentah
  final Laporan report;
  final VoidCallback? onTap;

  const ActivityReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- 2. LOGIKA FORMATTING ADA DI SINI ---
    DateTime dateTime = DateTime.now();
    try {
      if (report.tanggalIso != null && report.jam != null) {
        dateTime = DateTime.parse("${report.tanggalIso} ${report.jam}");
      }
    } catch (_) {}

    final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
    final formattedTime = report.jam ?? "--:--";
    // Gunakan fungsi .summary() dari model Laporan
    final summaryText = report.summary();
    // ---

    // 3. UI BARU (Sesuai desain Anda)
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom Kiri (Tanggal & Detail)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate, // <-- Gunakan data yang sudah diformat
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summaryText, // <-- Gunakan data yang sudah diformat
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Kolom Kanan (Jam)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 2.0), // Beri sedikit padding atas
                  child: Text(
                    formattedTime, // <-- Gunakan data yang sudah diformat
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}