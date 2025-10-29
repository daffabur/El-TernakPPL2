import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_item_modal.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/custom_report_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final List<Map<String, dynamic>> _rawReportData = [
    {"report_date": "2024-05-12T09:10:00.000Z", "details": "Bobot: 1.5 kg | Mati: 1 | Pakan: 125 kg"},
    {"report_date": "2024-06-12T09:10:00.000Z", "details": "Bobot: 1.5 kg | Mati: 1 | Pakan: 125 kg"},
    {"report_date": "2024-06-11T09:15:00.000Z", "details": "Bobot: 1.4 kg | Mati: 2 | Pakan: 122 kg"},
    {"report_date": "2024-04-12T09:10:00.000Z", "details": "Bobot: 1.3 kg | Mati: 4 | Pakan: 120 kg"},
    {"report_date": "2024-04-11T09:12:00.000Z", "details": "Bobot: 1.3 kg | Mati: 4 | Pakan: 120 kg"},
  ];

  List<ReportItem> _processedReports = [];

  @override
  void initState() {
    super.initState();
    _processedReports = _rawReportData
        .map((jsonData) => ReportItem.fromJson(jsonData))
        .toList();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      print("Date selected: $picked");
      // TODO: Implement filtering logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Riwayat Laporan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppStyles.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Button
            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade700),
              label: Text(
                'dd/mm/yyyy',
                style: GoogleFonts.poppins(color: Colors.grey.shade700),
              ),
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),
            // Delegate the list building to the ReportList widget
            CustomReportList(reports: _processedReports),
          ],
        ),
      ),
    );
  }
}