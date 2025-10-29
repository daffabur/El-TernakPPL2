// lib/screens/Supervisor/Cage_Management/widgets/report_list.dart
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_item_modal.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_ReportCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class CustomReportList extends StatelessWidget {
  final List<ReportItem> reports;

  const CustomReportList({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Center(child: Text("Belum ada laporan."));
    }

    final groupedData = <String, List<ReportItem>>{};
    for (final report in reports) {
      final month = DateFormat('MMMM yyyy', 'id_ID').format(report.date);
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
                date: DateFormat('dd MMMM yyyy', 'id_ID').format(report.date),
                details: report.details,
                time: DateFormat('HH.mm').format(report.date),
                onTap: () {
                  print("Report for ${report.date} tapped!");
                  // Jika Anda punya detail lebih lanjut di objek 'report', Anda bisa menampilkannya di sini
                },
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }
}