import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/custom_report_list.dart';
import 'package:el_ternak_ppl2/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- 1. IMPORT WIDGET DIALOG ANDA ---
import 'package:el_ternak_ppl2/base/widgets/app_dialogs.dart';

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

  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _loadReports(); // Sekarang memanggil fungsi async
  }

  // --- 2. REVISI _loadReports ---
  // Ubah menjadi async dan tambahkan try-catch
  Future<void> _loadReports() async {
    // 1. Tetap set state future-nya agar FutureBuilder menampilkan loading
    final future = _reportService.getByCageId(widget.cageId, date: _filterDate);
    setState(() {
      _reportsFuture = future;
    });

    try {
      // 2. Await future yang sama, HANYA untuk menangkap error
      await future;
    } catch (e) {
      // 3. Jika terjadi error, panggil dialog kustom Anda
      if (mounted) {
        // Gunakan AppDialogs.showError
        AppDialogs.showError(
          context,
          title: "Gagal Memuat",
          message: e.toString().replaceAll("Exception: ", ""),
        );
      }
    }
  }

  // (Fungsi _selectDate dan _clearFilter tidak berubah)
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _filterDate = picked;
      });
      _loadReports();
    }
  }

  void _clearFilter() {
    setState(() {
      _filterDate = null;
    });
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // (AppBar tidak berubah)
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
        onRefresh: () async => _loadReports(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // (UI Filter tidak berubah)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: Icon(Icons.calendar_today_outlined,
                          size: 16, color: Colors.grey.shade700),
                      label: Text(
                        _filterDate == null
                            ? 'Pilih Tanggal'
                            : DateFormat('d MMM yyyy', 'id_ID')
                            .format(_filterDate!),
                        style: GoogleFonts.poppins(
                            color: _filterDate == null
                                ? Colors.grey.shade700
                                : AppStyles.primaryColor,
                            fontWeight: _filterDate == null
                                ? FontWeight.normal
                                : FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: BorderSide(
                            color: _filterDate == null
                                ? Colors.grey.shade400
                                : AppStyles.primaryColor,
                            width: _filterDate == null ? 1 : 1.5),
                      ),
                    ),
                  ),
                  if (_filterDate != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: Colors.red.shade700),
                        onPressed: _clearFilter,
                        tooltip: "Hapus Filter",
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // FutureBuilder
              FutureBuilder<List<Report>>(
                future: _reportsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // --- 3. REVISI TAMPILAN ERROR ---
                  // Karena dialog sudah muncul, kita hanya perlu
                  // menampilkan UI yang bersih di sini.
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text(
                              "Gagal memuat data",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50.0),
                        child: Text(
                          _filterDate == null
                              ? "Belum ada data laporan."
                              : "Tidak ada laporan ditemukan untuk tanggal ini.",
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  }

                  final reports = snapshot.data!;
                  return CustomReportList(
                      reports: reports.reversed
                          .toList());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}