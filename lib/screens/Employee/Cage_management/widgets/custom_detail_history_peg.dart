import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Employee/bottom_nav_bar_peg.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDetailHistoryPeg extends StatefulWidget {
  final int laporanId;

  const CustomDetailHistoryPeg({super.key, required this.laporanId});

  @override
  State<CustomDetailHistoryPeg> createState() => _CustomDetailHistoryPegState();
}

class _CustomDetailHistoryPegState extends State<CustomDetailHistoryPeg> {
  final _service = CageService();

  bool _loading = true;
  String? _error;
  Laporan? _lap;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getLaporanById(widget.laporanId);
      if (!mounted) return;
      setState(() {
        _lap = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatTanggalIndo(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso); // "yyyy-MM-dd"
      const bulan = [
        '',
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
      final b = (dt.month >= 1 && dt.month <= 12)
          ? bulan[dt.month]
          : '${dt.month}';
      return '${dt.day} $b ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _numStr(num? n) {
    if (n == null) return '-';
    final s = n.toString();
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF3E7B27),
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      centerTitle: true,
      title: Text(
        'Details', // <- PAKSA judul "Details" sesuai mockup
        style: GoogleFonts.poppins(
          color: AppStyles.primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _headerTanggalJam(Laporan lap) {
    final tgl = _formatTanggalIndo(lap.tanggalIso);
    final jam = lap.jam ?? '-';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tgl,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF2A2A2A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                jam,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: Color(0xFFE6E6E6)),
      ],
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppStyles.primaryColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) return const LinearProgressIndicator(minHeight: 3);
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat detail laporan:\n$_error',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13.5),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    final lap = _lap!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        _headerTanggalJam(lap),

        _rowItem('Rata rata Bobot ayam', '${_numStr(lap.bobot)} Kg'),
        _rowItem('Kematian ayam', '${lap.mati ?? 0} Ekor'),
        _rowItem('Pakan digunakan', '${_numStr(lap.pakan)} Kg'),
        _rowItem('Sekam digunakan', '${_numStr(lap.sekam)} Kg'),
        _rowItem('Solar digunakan', '${_numStr(lap.solar)} L'),
        _rowItem('Obat digunakan', '${_numStr(lap.obat)} L'),

        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE6E6E6)),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Laporan (coming soon)')),
                );
              },
              child: Text(
                'Edit Laporan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _content(),
        ),
      ),
      bottomNavigationBar: const BottomNavBarPeg(),
    );
  }
}
