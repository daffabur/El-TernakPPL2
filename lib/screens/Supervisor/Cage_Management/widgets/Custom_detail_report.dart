import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:el_ternak_ppl2/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CustomDetailReport extends StatefulWidget {

  final int reportId;

  const CustomDetailReport({
    super.key,
    required this.reportId,
  });

  @override
  State<CustomDetailReport> createState() => _CustomDetailReportState();
}

class _CustomDetailReportState extends State<CustomDetailReport> {
  final ReportService _reportService = ReportService();
  late Future<Report> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _reportService.getReportById(widget.reportId);
  }

  // ... (helper _buildDetailRow tidak berubah)
  Widget _buildDetailRow(BuildContext context, {required String label, required String value}) {
    final labelStyle = GoogleFonts.poppins(
      fontSize: 16,
      color: AppStyles.primaryColor
    );
    final valueStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppStyles.primaryColor
    );

    return Padding(
      // Beri jarak vertikal antar baris
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppStyles.primaryColor,
        ),
        title: Text(
          "Details",
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: AppStyles.primaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      // Gunakan FutureBuilder untuk menangani data
      body: FutureBuilder<Report>(
        future: _reportFuture,
        builder: (context, snapshot) {
          // 1. State Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. State Error
          if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat detail: ${snapshot.error}"));
          }

          // 3. State Sukses
          if (snapshot.hasData) {
            final report = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Header Tanggal dan Jam
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        report.tanggal,
                        style: GoogleFonts.poppins(fontSize: 20,  color: AppStyles.primaryColor,),
                      ),
                      Text(
                        report.jam,
                        style: GoogleFonts.poppins(fontSize: 20, color: AppStyles.primaryColor,),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1),

                  // Daftar Detail
                  _buildDetailRow(context, label: "Pencatat", value: report.pencatat),
                  _buildDetailRow(context, label: "Rata-rata Bobot", value: "${report.bobot} Kg"),
                  _buildDetailRow(context, label: "Kematian", value: "${report.mati} Ekor"),
                  _buildDetailRow(context, label: "Pakan digunakan", value: "${report.pakan} Kg"),
                  // Gunakan ?? 0 untuk menampilkan 0 jika data null
                  _buildDetailRow(context, label: "Sekam digunakan", value: "${report.sekam ?? 0} Kg"),
                  _buildDetailRow(context, label: "Solar digunakan", value: "${report.solar ?? 0} L"),
                  _buildDetailRow(context, label: "Obat digunakan", value: "${report.obat ?? 0} L"),

                ],
              ),
            );
          }

          // Fallback jika tidak ada data
          return const Center(child: Text("Detail laporan tidak ditemukan."));
        },
      ),
    );
  }
}

