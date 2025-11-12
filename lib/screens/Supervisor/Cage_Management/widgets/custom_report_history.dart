import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/custom_report_list.dart';
import 'package:el_ternak_ppl2/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ReportHistoryScreen extends StatefulWidget {
  final int cageId;
  final String cageName;

  const ReportHistoryScreen({
    super.key,
    required this.cageId,
    required this.cageName,
  });

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final ReportService _reportService = ReportService();
  late Future<List<Report>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }
  void _loadReports() {
    setState(() {
      _reportsFuture = _reportService.getByCageId(widget.cageId);
    });
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
          "Riwayat: ${widget.cageName}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppStyles.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
          child: SingleChildScrollView(
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
            FutureBuilder<List<Report>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                // Saat loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Jika ada error
                if (snapshot.hasError) {
                  return Center(child: Text("Gagal memuat: ${snapshot.error}"));
                }

                // Jika data berhasil didapat (meski kosong)
                if (snapshot.hasData) {
                  // Teruskan data ke CustomReportList
                  return CustomReportList(reports: snapshot.data!);
                }

                // Kondisi fallback jika terjadi hal aneh
                return const Center(child: Text("Tidak ada data."));
              },
            )
              ],
            ),
          ),
          onRefresh: () async => _loadReports(),)
    );
  }
}