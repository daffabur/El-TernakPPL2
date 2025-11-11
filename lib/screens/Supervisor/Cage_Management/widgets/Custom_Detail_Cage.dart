import 'dart:convert';
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_ReportCard.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_detail_report.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/custom_report_history.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:el_ternak_ppl2/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home_screen.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/money_management.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/cage_management.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/account_management.dart';
import 'package:intl/intl.dart';

// Import model User untuk menangani data tim
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';

class CustomDetailCage extends StatefulWidget {
  final Cage cage;

  const CustomDetailCage({super.key, required this.cage});

  @override
  State<CustomDetailCage> createState() => _CustomDetailCageState();
}

class _CustomDetailCageState extends State<CustomDetailCage> {
  final _cageService = CageService();
  final _reportService = ReportService();

  Cage? _cage;
  List<Report> _reports = [];
  bool _loading = true;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _cage = widget.cage;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (mounted) setState(() => _loading = true);

    try {
      // Ambil detail kandang (termasuk data 'team' yang baru) dan laporan
      final freshCageFuture = _cageService.getById(widget.cage.id);
      final reportsFuture = _reportService.getByCageId(widget.cage.id);

      final results = await Future.wait([freshCageFuture, reportsFuture]);

      final freshCage = results[0] as Cage;
      final reports = results[1] as List<Report>;

      if (!mounted) return;
      setState(() {
        _cage = freshCage;
        _reports = reports;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      print("Error _loadDetail: $e");
      setState(() {
        _cage = widget.cage;
        _reports = [];
        _loading = false;
      });
    }
  }

  (String label, Color bg, Color border, Color text) _statusStyle(String s) {
    final status = s.trim().toLowerCase();
    if (status == 'inactive' ||
        status.contains('non') ||
        status.contains('inaktif')) {
      return ('Nonaktif', Colors.red.shade50, Colors.red, Colors.red);
    }
    if (status == 'active' || status.contains('aktif')) {
      return ('Aktif', Colors.green.shade50, Colors.green, Colors.green);
    }
    return (s, Colors.grey.shade100, Colors.grey, Colors.grey);
  }

  Future<void> _confirmAndDelete() async {
    if (_deleting) return;
    final name = _cage?.name ?? widget.cage.name;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kandang?'),
        content: Text(
          'Kamu akan menghapus "$name". Tindakan ini tidak bisa dibatalkan.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      setState(() => _deleting = true);
      await _cageService.deleteById(widget.cage.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kandang "$name" berhasil dihapus')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus kandang: $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _cage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cage = _cage!;

    // --- LOGIKA BARU UNTUK MENDAPATKAN PJ DAN TIM ---
    // Gunakan helper 'pj' dari model Cage
    final User? pj = cage.pj;
    // Ambil seluruh tim
    final List<User> team = cage.team;

    // Tentukan teks yang akan ditampilkan (nama PJ atau fallback)
    final String picText = pj?.username ?? 'Belum Ditentukan';
    // --- AKHIR LOGIKA BARU ---

    final (label, bg, border, text) = _statusStyle(cage.status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppStyles.IconCageCardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Iconify(
                MaterialSymbols.house_siding,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              cage.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppStyles.primaryColor,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER: PIC (Dropdown) + Status ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- Dropdown Lihat Tim ---
                  PopupMenuButton<User>(
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    elevation: 3,
                    onSelected: (User user) {
                      // Read-only, tidak ada aksi
                    },
                    // Tombol Utama (Tampilan Nama PJ)
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar placeholder / icon
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person,
                                size: 16, color: Colors.blue.shade700),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            picText,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 20, color: Colors.black54),
                        ],
                      ),
                    ),
                    // Isi Menu Dropdown (Daftar Tim)
                    itemBuilder: (BuildContext context) {
                      if (team.isEmpty) {
                        return [
                          const PopupMenuItem(
                              enabled: false, child: Text("Tidak ada tim"))
                        ];
                      }

                      return team.map((User user) {
                        return PopupMenuItem<User>(
                          value: user,
                          enabled: false, // Read-only
                          height: 40,
                          child: Row(
                            children: [
                              // Indikator PJ vs Anggota
                              Icon(
                                user.isPj
                                    ? Icons.star_rounded
                                    : Icons.circle,
                                color: user.isPj
                                    ? Colors.amber.shade600
                                    : Colors.grey.shade300,
                                size: user.isPj ? 20 : 12,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.username,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: user.isPj
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: user.isPj
                                        ? Colors.black87
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              if (user.isPj)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.amber.shade200),
                                  ),
                                  child: Text(
                                    "PJ",
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.amber.shade800,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),

                  // Badge Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: border, width: 1.2),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Kartu Populasi
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppStyles.highlightColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Opacity(
                        opacity: 1,
                        child: SvgPicture.asset(
                          "assets/images/ic_populasi.svg",
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.width * 0.3,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        bottom: 20,
                        top: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Populasi",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${cage.population}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Kematian",
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                          Text(
                            "${cage.deaths}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Kartu Sekam & Solar
              Row(
                children: [
                  Expanded(
                    child: _smallStatCard(
                      title: "Sekam Digunakan",
                      value: "${cage.sekam ?? 0} Kg",
                      asset: "assets/images/ic_sekam.svg",
                      assetScale: 0.15,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _smallStatCard(
                      title: "Solar Digunakan",
                      value: "${cage.solar ?? 0} L",
                      asset: "assets/images/ic_solar.svg",
                      assetScale: 0.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Kartu Pakan
              _wideStatCard(
                title: "Konsumsi Pakan",
                value: "${cage.pakan ?? 0} Kg",
                asset: "assets/images/ic_pakan.svg",
                assetScale: 0.25,
              ),

              const SizedBox(height: 15),

              // Kartu Obat
              _wideStatCard(
                title: "Obat",
                value: "${cage.obat ?? 0} L",
                asset: "assets/images/ic_obat.svg",
                assetScale: 0.2,
              ),

              const SizedBox(height: 24),

              // Judul Laporan Terbaru
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Laporan Terbaru",
                    style: GoogleFonts.poppins(
                        color: AppStyles.primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportHistoryScreen(
                                cageId: cage.id,
                                cageName: cage.name,
                              )),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: BorderSide(
                            color: AppStyles.primaryColor, width: 1.5),
                        foregroundColor: AppStyles.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Lihat Lengkap',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ))
                ],
              ),
              const SizedBox(height: 16),

              // Daftar Laporan
              _loading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(),
                ),
              )
                  : _reports.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded,
                        color: Colors.grey.shade300, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      "Belum ada laporan terbaru",
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
                  : Column(
                children: _reports.reversed
                    .toList()
                    .take(4)
                    .map((report) {
                  final combinedDateTimeString =
                      '${report.tanggal} ${report.jam}';
                  DateTime dateTime;
                  try {
                    dateTime = DateTime.parse(combinedDateTimeString);
                  } catch (e) {
                    dateTime = DateTime.now();
                  }
                  final formattedDate =
                  DateFormat('dd MMMM yyyy', 'id_ID')
                      .format(dateTime);
                  final formattedTime =
                      DateFormat('HH:mm', 'id_ID').format(dateTime) +
                          ' WIB';

                  return CustomReportcard(
                    date: formattedDate,
                    time: formattedTime,
                    details:
                    "Bobot: ${report.bobot} kg | Mati: ${report.mati} | Pakan: ${report.pakan} kg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomDetailReport(
                            reportId: report.id,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              // Tombol Hapus Kandang
              SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: OutlinedButton(
                      onPressed: _deleting ? null : _confirmAndDelete,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                        foregroundColor: Colors.red.shade500,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: _deleting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                        ),
                      )
                          : Text(
                        'Hapus Kandang',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ===== helper UI kecil =====
  Widget _smallStatCard({
    required String title,
    required String value,
    required String asset,
    required double assetScale,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.highlightColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 1,
              child: SvgPicture.asset(
                asset,
                width: MediaQuery.of(context).size.width * assetScale,
                height: MediaQuery.of(context).size.width * assetScale,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideStatCard({
    required String title,
    required String value,
    required String asset,
    required double assetScale,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppStyles.highlightColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 1,
              child: SvgPicture.asset(
                asset,
                width: MediaQuery.of(context).size.width * assetScale,
                height: MediaQuery.of(context).size.width * assetScale,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}