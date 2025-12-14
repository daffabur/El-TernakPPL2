import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/login.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_Management/widgets/custom_detail_cage_peg.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// --- IMPORT WIDGET & SCREEN PENDUKUNG ---
import 'package:el_ternak_ppl2/screens/Employee/Cage_management/widgets/activity_report_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/widgets/Custom_detail_report.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CageService _cageService = CageService();

  Cage? _cage;
  List<Laporan> _riwayatLaporan = []; // Menyimpan list laporan untuk aktivitas
  bool _isLoading = true;
  String? _error;

  bool _sudahInputHariIni = false;
  Laporan? _laporanTerakhir;
  int _hariKe = 1; // Masih dummy/hardcoded karena belum ada logic siklus

  DateTime get _today => DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Helper tanggal
  DateTime _combineToDateTime(Laporan lap) {
    try {
      final date = DateTime.parse(lap.tanggalIso ?? '');
      final hhmm = (lap.jam ?? '00:00').split(':');
      final h = int.tryParse(hhmm.elementAt(0)) ?? 0;
      final m = int.tryParse(hhmm.elementAt(1)) ?? 0;
      return DateTime(date.year, date.month, date.day, h, m);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _checkInputStatus(List<Laporan> riwayat) {
    if (riwayat.isEmpty) {
      if (mounted) setState(() => _sudahInputHariIni = false);
      return;
    }

    final laporanTerbaru = riwayat.first;
    DateTime tanggalLaporan;

    try {
      tanggalLaporan = DateTime.parse(laporanTerbaru.tanggalIso ?? '');
    } catch (e) {
      if (mounted) setState(() => _sudahInputHariIni = false);
      return;
    }

    if (_isToday(tanggalLaporan)) {
      if (mounted) {
        setState(() {
          _sudahInputHariIni = true;
          _laporanTerakhir = laporanTerbaru;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _sudahInputHariIni = false;
          _laporanTerakhir = null;
        });
      }
    }
  }

  // --- REVISI UTAMA DI _loadData() ---
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Panggil kedua API secara paralel (bersamaan)
      final results = await Future.wait([
        _cageService.getForEmployee(), // API #1
        _cageService.getLaporanForMe(), // API #2 (Baru)
      ]);

      if (!mounted) return;

      final cages = results[0] as List<Cage>;
      final riwayat = results[1] as List<Laporan>;

      if (cages.isNotEmpty) {
        // Urutkan riwayat (DESC) agar laporan terbaru ada di [0]
        riwayat.sort(
          (a, b) => _combineToDateTime(b).compareTo(_combineToDateTime(a)),
        );

        setState(() {
          _cage = cages.first; // Simpan kandang
          _riwayatLaporan = riwayat; // Simpan riwayat
          _isLoading = false;
        });

        // Cek status input (sekarang dengan data yang sudah di-sort)
        _checkInputStatus(riwayat);
      } else {
        setState(() {
          _error = "Anda tidak ditugaskan ke kandang manapun.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Gagal memuat data: ${e.toString()}";
        _isLoading = false;
      });
    }
  }
  // --- AKHIR REVISI ---

  void _navigateToDetail() {
    if (_cage == null) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CustomDetailCagePeg(cage: _cage!),
          ),
        )
        .then((_) {
          _loadData(); // Refresh saat kembali
        });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar Akun?'),
        content: const Text('Anda akan keluar dari aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final authService = context.read<AuthService>();
    authService.logout();

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = AppStyles.highlightColor;
    final String employeeName =
        context.watch<AuthService>().username ?? 'Pegawai';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(
                'assets/images/avatar_placeholder.png',
              ),
            ),
            const SizedBox(width: 10),
            Text(
              employeeName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
            icon: Icon(Icons.logout_rounded, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorView(_error!)
            : _cage == null
            ? _buildErrorView("Kandang tidak ditemukan.")
            : _buildContent(context, green, employeeName),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color green, String employeeName) {
    final cage = _cage!;

    // Data Ringkasan Harian
    final int kematianHarian = _laporanTerakhir?.mati ?? 0;
    final String pakanHarian = "${_laporanTerakhir?.pakan ?? 0} kg";
    final String sekamHarian = "${_laporanTerakhir?.sekam ?? 0} kg";
    final String obatHarian = "${_laporanTerakhir?.obat ?? 0} L";
    final String jamLaporan = _laporanTerakhir?.jam ?? "--:--";

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARTU TUGAS HARI INI
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Input Data Kandang',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _sudahInputHariIni
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _sudahInputHariIni
                                  ? Colors.green
                                  : Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _sudahInputHariIni
                                ? 'Sudah dikerjakan'
                                : 'Belum dikerjakan',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: _sudahInputHariIni
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: green,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _navigateToDetail,
                      child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. KARTU REKAP HARIAN (HIJAU)
            Container(
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _formatTanggal(_today),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        jamLaporan,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metricItem('Kematian', '$kematianHarian ekor'),
                      _metricItem('Pakan', pakanHarian),
                      _metricItem('Sekam', sekamHarian),
                      _metricItem('Obat', obatHarian),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. TWIN CARDS (Populasi & Kematian Total)
            Row(
              children: [
                Expanded(
                  child: _smallTotalCard(
                    title: 'Total Populasi',
                    value: cage.population.toString(),
                    tag: cage.name,
                    asset: 'assets/images/ic_populasi.svg',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _smallTotalCard(
                    title: 'Total Kematian',
                    value: cage.deaths.toString(),
                    tag: cage.name,
                    asset: 'assets/images/ic_obat.svg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. AKTIVITAS KANDANG (NEW UI SECTION)
            Text(
              'Aktivitas Kandang',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            if (_riwayatLaporan.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_edu_rounded,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Belum ada aktivitas laporan.",
                      style: GoogleFonts.poppins(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
            else
              // Tampilkan (misalnya) 5 laporan terbaru saja
              Column(
                children: _riwayatLaporan.take(5).map((report) {
                  return ActivityReportCard(
                    report: report, // <-- Kirim objek Laporan utuh
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomDetailReport(reportId: report.id),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricItem(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _smallTotalCard({
    required String title,
    required String value,
    required String tag,
    required String asset,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.highlightColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Stack(
        children: [
          Positioned(
            right: -4,
            bottom: -6,
            child: Opacity(
              opacity: 0.9,
              child: SvgPicture.asset(
                asset,
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: .8),
                    ),
                    child: Text(
                      tag,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  String _formatJam(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }
}
