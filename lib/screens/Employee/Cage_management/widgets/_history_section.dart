import 'package:el_ternak_ppl2/screens/Employee/Cage_management/widgets/Custom_detail_report.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class HistorySection extends StatelessWidget {
  final bool isLoading;
  final List<Laporan> historyItems;
  final VoidCallback onRefresh;

  const HistorySection({
    super.key,
    required this.isLoading,
    required this.historyItems,
    required this.onRefresh,
  });

  String _formatTanggalIndo(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso); // "yyyy-MM-dd"
      const bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
        'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      final b = (dt.month >= 1 && dt.month <= 12) ? bulan[dt.month] : '${dt.month}';
      return '${dt.day} $b ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest4 = historyItems.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Laporan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2F4F2F),
          ),
        ),
        const SizedBox(height: 12),

        // --- KONDISI LOADING ---
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          )
        // --- KONDISI KOSONG ---
        else if (latest4.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)
            ),
            child: Column(
              children: [
                Icon(Icons.history_toggle_off_rounded, size: 32, color: Colors.grey.shade400,),
                const SizedBox(height: 8),
                Text(
                  'Belum ada riwayat laporan.',
                  style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black54),
                ),
              ],
            ),
          )
        // --- KONDISI ADA DATA ---
        else
          Column(
            children: latest4.map((lap) {
              final tgl = _formatTanggalIndo(lap.tanggalIso);
              final jam = lap.jam ?? '';
              final ringkas = lap.summary();

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                    builder: (context) => CustomDetailReport(reportId: lap.id),
                  ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.04),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFECECEC)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tgl,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2A2A2A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 16, color: Colors.black45),
                                const SizedBox(width: 4),
                                Text(
                                  jam,
                                  style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ringkas,
                          style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
