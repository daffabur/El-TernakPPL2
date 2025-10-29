// lib/screens/Employee/Cage_Management/widgets/custom_detail_cage_peg.dart
import 'dart:io';

import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_Management/widgets/custom_input_harian_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

// === Tambah: import halaman detail riwayat
import 'package:el_ternak_ppl2/screens/Employee/Cage_Management/widgets/custom_detail_history_peg.dart';

class CustomDetailCagePeg extends StatefulWidget {
  final Cage cage;
  const CustomDetailCagePeg({super.key, required this.cage});

  @override
  State<CustomDetailCagePeg> createState() => _CustomDetailCagePegState();
}

class _CustomDetailCagePegState extends State<CustomDetailCagePeg> {
  final _service = CageService();

  static const _inputCardKey = ValueKey('input-harian-card');

  Cage? _detail;
  bool _loading = true;
  String? _error;

  // -> kontrol visibilitas kartu input dari parent
  bool _hideInput = false;

  // ===== Riwayat dari API =====
  List<Laporan> _riwayat = <Laporan>[];
  bool _loadingRiwayat = false;

  @override
  void initState() {
    super.initState();
    _load(initial: true);
  }

  Future<void> _load({bool initial = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = widget.cage.id;
      if (id == null || id <= 0) {
        if (initial) _detail = widget.cage;
        throw Exception('ID kandang tidak valid (${id ?? "null"}).');
      }
      final fresh = await _service.getById(id);
      if (!mounted) return;

      setState(() {
        _detail = fresh;
        _loading = false;
      });

      // Setelah detail berhasil, ambil riwayat
      await _loadRiwayat(fresh.id ?? id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detail ??= widget.cage;
        _loading = false;
        _error = e.toString();
      });
      final fallbackId = widget.cage.id;
      if (fallbackId != null && fallbackId > 0) {
        await _loadRiwayat(fallbackId);
      }
    }
  }

  // Gabungkan tanggal (YYYY-MM-DD) + jam (HH:mm) jadi DateTime untuk sorting
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

  Future<void> _loadRiwayat(int kandangId) async {
    setState(() {
      _loadingRiwayat = true;
    });
    try {
      final items = await _service.getLaporanPerKandang(kandangId);
      // Sort DESC (terbaru di atas)
      items.sort(
        (a, b) => _combineToDateTime(b).compareTo(_combineToDateTime(a)),
      );

      if (!mounted) return;
      setState(() {
        _riwayat = items;
        _loadingRiwayat = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _riwayat = <Laporan>[];
        _loadingRiwayat = false;
      });
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  num _numFrom(Map<String, num> m, List<String> keys, {num def = 0}) {
    for (final k in keys) {
      if (m.containsKey(k)) return m[k] ?? def;
    }
    return def;
  }

  Future<void> _submitHarian(Map<String, num> data) async {
    final kematian = _numFrom(data, ['kematian_ayam', 'kematian']);
    final rataBobot = _numFrom(data, [
      'rata_bobot_ayam',
      'ratarata',
      'ratarat',
    ]);
    final pakan = _numFrom(data, ['pakan_used', 'pakan']);
    final solar = _numFrom(data, ['solar_used', 'solar']);
    final sekam = _numFrom(data, ['sekam_used', 'sekam']);
    final obat = _numFrom(data, ['obat_used', 'obat']);

    final id = widget.cage.id ?? _detail?.id ?? -1;
    if (id <= 0) {
      _showSnack('ID kandang tidak valid, tidak bisa mengirim laporan.');
      return;
    }

    try {
      await _service.createLaporan(
        kandangId: id,
        kematianAyam: kematian.toInt(),
        rataBobotAyam: rataBobot,
        pakanUsed: pakan,
        solarUsed: solar,
        sekamUsed: sekam,
        obatUsed: obat,
      );

      if (!mounted) return;
      _showSnack('Laporan harian BERHASIL dikirim ke server.');

      // === AUTO RELOAD TANPA DELAY ===
      setState(() {
        _hideInput = true; // tetap sembunyikan form seperti sebelumnya
      });

      // Refresh riwayat & angka di kartu statistik secara paralel
      await Future.wait([
        _loadRiwayat(id),
        () async {
          try {
            final fresh = await _service.getById(id);
            if (!mounted) return;
            setState(() => _detail = fresh);
          } catch (_) {}
        }(),
      ]);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal mengirim laporan: $e');
    }
  }

  PreferredSizeWidget _buildAppBar({required String title}) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 48,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF3E7B27),
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppStyles.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Iconify(
              MaterialSymbols.home_work_rounded,
              size: 18,
              color: Color(0xFF3E7B27),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: AppStyles.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStatCard({
    required String title,
    required String value,
    required String asset,
    required double assetScale,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.highlightColor,
        borderRadius: BorderRadius.circular(16),
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
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(16),
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
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================
  //  RIWAYAT LAPORAN (API)
  // =======================
  String _formatTanggalIndo(String? iso) {
    if (iso == null || iso.isEmpty) return '';
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

  // === Riwayat: tap => buka halaman Details (judul "Details")
  Widget _riwayatSection() {
    // Ambil 4 terbaru saja
    final latest4 = _riwayat.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Riwayat Laporan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2F4F2F),
          ),
        ),
        const SizedBox(height: 12),

        if (_loadingRiwayat)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else if (latest4.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Belum ada riwayat.',
              style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black54),
            ),
          )
        else
          ...latest4.map((lap) {
            final tgl = _formatTanggalIndo(lap.tanggalIso);
            final jam = lap.jam ?? '';
            final ringkas = lap.summary();

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CustomDetailHistoryPeg(
                      laporanId: lap.id, // <-- TIDAK kirim kandangName
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                      color: Colors.black.withOpacity(0.04),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFECECEC)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tgl,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2A2A2A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                jam,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ringkas,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cageTitle = (_detail ?? widget.cage).name;

    if (_error != null && _detail == null) {
      return _errorView(_error!);
    }

    final cage = _detail ?? widget.cage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(title: cageTitle),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!_hideInput)
                    CustomInputHarianCard(
                      key: _inputCardKey,
                      onSubmit: _submitHarian,
                      submitterName: cage.pic,
                    ),
                  if (!_hideInput) const SizedBox(height: 16),

                  // Kartu Populasi
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppStyles.highlightColor,
                      borderRadius: BorderRadius.circular(16),
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
                              width: MediaQuery.of(context).size.width * 0.30,
                              height: MediaQuery.of(context).size.width * 0.30,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Populasi",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${cage.population}",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
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

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _smallStatCard(
                          title: "Sekam digunakan",
                          value: "${cage.sekam ?? 0} kg",
                          asset: "assets/images/ic_sekam.svg",
                          assetScale: 0.16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _smallStatCard(
                          title: "Solar digunakan",
                          value: "${cage.solar ?? 0} L",
                          asset: "assets/images/ic_solar.svg",
                          assetScale: 0.20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _wideStatCard(
                    title: "Konsumsi Pakan",
                    value: "${cage.pakan ?? 0} kg",
                    asset: "assets/images/ic_pakan.svg",
                    assetScale: 0.25,
                  ),

                  const SizedBox(height: 12),

                  _wideStatCard(
                    title: "Obat",
                    value: "${cage.obat ?? 0} L",
                    asset: "assets/images/ic_obat.svg",
                    assetScale: 0.22,
                  ),

                  const SizedBox(height: 16),

                  // === RIWAYAT LAPORAN (4 terbaru) + tap => detail ===
                  _riwayatSection(),
                ],
              ),
            ),
          ),

          if (_loading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
        ],
      ),
    );
  }

  Widget _errorView(String message) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(title: 'Informasi Kandang'),
      body: Center(
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
                'Gagal memuat kandang:\n$message',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _load(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
