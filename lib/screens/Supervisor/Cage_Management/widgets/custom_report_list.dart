// lib/screens/Supervisor/Cage_Management/widgets/report_list.dart
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_ReportCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class CustomReportList extends StatelessWidget {
  final List<Report> reports;

  const CustomReportList({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          child: Text("Belum ada laporan."),
        ),
      );
    }

    final groupedData = <String, List<Report>>{};
    for (final report in reports) {
      // Konversi string 'YYYY-MM-DD' dari API menjadi objek DateTime
      final date = DateTime.tryParse(report.tanggal);
      if (date == null) continue; // Lewati jika format tanggal tidak valid

      // Kunci pengelompokan (contoh: "Oktober 2025")
      final month = DateFormat('MMMM yyyy', 'id_ID').format(date);
      if (groupedData[month] == null) {
        groupedData[month] = [];
      }
      groupedData[month]!.add(report);
    }


    return Column(
      children: groupedData.entries.map((entry) {
        final month = entry.key;
        final reportsInMonth = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 12.0, 0, 8.0),
              child: Text(
                month,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.primaryColor,
                ),
              ),
            ),
            ...reportsInMonth.map((report) {
              // *** USE YOUR CUSTOM WIDGET HERE ***
              return CustomReportcard(
                date: report.tanggal,
                details: "Bobot: ${report.bobot} kg | Mati: ${report.mati} | Pakan: ${report.pakan} kg",
                time: report.jam,
                onTap: () {
                  print("Report for ${report.tanggal} tapped!");
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dicatat oleh: ${report.pencatat}'))
                  );
                },
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }
}