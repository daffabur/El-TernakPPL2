// lib/screens/Supervisor/Cage_Management/widgets/ReportItemCard.dart

import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget ini HANYA untuk menampilkan UI.
class ReportItemCard extends StatelessWidget {
  // Ia menerima satu objek 'Report' yang lengkap.
  final Report report;
  final VoidCallback? onTap;

  const ReportItemCard({
    super.key,
    required this.report,
    this.onTap,
  });

  // Helper widget untuk membuat baris detail dengan ikon
  Widget _buildDetailRow(IconData icon, Color iconColor, String value, String unit) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAGIAN HEADER (TANGGAL, JAM, PENCATAT) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      report.tanggal,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      report.jam,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Dicatat oleh ${report.pencatat}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Divider(height: 24, thickness: 0.5),

                // --- BAGIAN DETAIL LAPORAN DENGAN IKON ---
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 kolom
                    childAspectRatio: 4 / 1, // Rasio lebar-tinggi setiap item
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  children: [
                    _buildDetailRow(Icons.scale_outlined, Colors.blue.shade700, report.bobot.toString(), 'Kg'),
                    _buildDetailRow(Icons.heart_broken_outlined, Colors.red.shade700, report.mati.toString(), 'Ekor'),
                    _buildDetailRow(Icons.restaurant_menu, Colors.brown.shade700, report.pakan.toString(), 'Kg'),
                    _buildDetailRow(Icons.local_gas_station_outlined, Colors.orange.shade800, report.solar.toString(), 'L'),
                    _buildDetailRow(Icons.grass_outlined, Colors.green.shade800, report.sekam.toString(), 'Karung'),
                    _buildDetailRow(Icons.medication_outlined, Colors.purple.shade700, report.obat.toString(), 'L'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
