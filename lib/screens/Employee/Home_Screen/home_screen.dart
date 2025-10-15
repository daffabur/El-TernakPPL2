import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/login.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Home page untuk Pegawai (dipakai oleh BottomNavBarPeg)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- Dummy data (silakan sambungkan ke BE nanti) ---
  String get _employeeName => 'Ehsan Bin Mail';
  int get _hariKe => 1;
  bool get _sudahInputHariIni => false;
  DateTime get _today => DateTime.now();

  // ringkasan harian
  int get _kematian => 200;
  String get _pakan => '13 kg';
  String get _sekam => '15 kg';
  String get _obat => '10 L';

  // total
  int get _totalPopulasi => 8000;
  int get _totalKematian => 1000;

  // ===== Logout helper =====
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

    // Bersihkan token (pakai saveToken('') agar kompatibel dengan AuthService kamu)
    final auth = AuthService();
    await auth.saveToken('');

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = AppStyles.highlightColor;

    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar putih tipis + tombol logout di kanan atas
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
              _employeeName,
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
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: tarik ulang data dari BE
            await Future<void>.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Kartu "Hari ke-1" + CTA Input =====
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Hari ke + title + status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Hari ke-$_hariKe',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 16,
                                  color: Colors.redAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
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
                      // tombol panah
                      Material(
                        color: green,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // TODO: navigasi ke halaman input data harian
                          },
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

                // ===== Kartu rekap harian (hijau) =====
                Container(
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      // baris tanggal & jam
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
                            _formatJam(_today),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // 4 kolom metrik
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _metricItem('Kematian', '$_kematian ekor'),
                          _metricItem('Pakan', _pakan),
                          _metricItem('Sekam', _sekam),
                          _metricItem('Obat', _obat),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ===== 2 kartu kecil (Total Populasi & Total Kematian) =====
                Row(
                  children: [
                    Expanded(
                      child: _smallTotalCard(
                        title: 'Total Populasi',
                        value: _totalPopulasi.toString(),
                        tag: 'Kandang 1',
                        asset: 'assets/images/ic_populasi.svg',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _smallTotalCard(
                        title: 'Total Kematian',
                        value: _totalKematian.toString(),
                        tag: 'Kandang 1',
                        asset: 'assets/images/ic_obat.svg', // contoh icon
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ===== Placeholder chart kotak besar =====
                Container(
                  height: 325,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Chart / Ringkasan Visual',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== Widgets kecil =====

  Widget _metricItem(String label, String value) {
    return Column(
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
  }

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
          // ilustrasi di kanan bawah (opsional)
          Positioned(
            right: -4,
            bottom: -6,
            child: Opacity(
              opacity: 0.9,
              child: SvgPicture.asset(asset, width: 52, height: 52),
            ),
          ),
          // konten
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // tag kecil kanan atas
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
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: .8),
                    ),
                    child: Text(
                      'Detail',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 9,
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
