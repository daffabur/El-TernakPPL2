import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_Management/widgets/custom_input_harian_card.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_management/widgets/_app_bar.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_management/widgets/_history_section.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_management/widgets/_stat_cards.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:flutter/material.dart';
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

  bool _isInputMode = false;

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

  Future<void> _submitHarian(Map<String, dynamic> data) async {
    // Ekstrak data dari payload Map<String, dynamic>
    final kematian = (data['kematian_ayam'] as num?) ?? 0;
    final rataBobot = (data['rata_bobot_ayam'] as num?) ?? 0;
    final pakan = (data['pakan_used'] as num?) ?? 0;
    final pakanTipe = (data['pakan_tipe'] as String?); // <-- Data baru (String)
    final solar = (data['solar_used'] as num?) ?? 0;
    final sekam = (data['sekam_used'] as num?) ?? 0;
    final obat = (data['obat_used'] as num?) ?? 0;
    final obatTipe = (data['obat_tipe'] as String?); // <-- Data baru (String)

    final id = widget.cage.id ?? _detail?.id ?? -1;
    if (id <= 0) {
      _showSnack('ID kandang tidak valid, tidak bisa mengirim laporan.');
      return;
    }

    try {
      print("Data Laporan yang akan dikirim (DEBUG):");
      print("Pakan: $pakanTipe - $pakan kg");
      print("Obat: $obatTipe - $obat L");

      await _service.createLaporan(
        kandangId: id,
        kematianAyam: kematian.toInt(),
        rataBobotAyam: rataBobot,
        pakanUsed: pakan,
        solarUsed: solar,
        sekamUsed: sekam,
        obatUsed: obat,
        pakanTipe: pakanTipe,
        obatTipe: obatTipe,
      );

      if (!mounted) return;
      _showSnack('Laporan harian BERHASIL dikirim ke server.');

      // Auto-reload data
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
      throw Exception('Gagal kirim: $e');
    }
  }

  // (Widget _buildInputTrigger tidak berubah)
  Widget _buildInputTrigger() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Input Data Kandang',
            style: GoogleFonts.poppins(
              color: AppStyles.primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _isInputMode = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.highlightColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: Text(
              'Buat Laporan',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // (Widget build() tidak berubah)
  @override
  Widget build(BuildContext context) {
    final cageTitle = (_detail ?? widget.cage).name;

    if (_error != null && _detail == null) {
      return _errorView(_error!);
    }

    final cage = _detail ?? widget.cage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(title: cageTitle),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_isInputMode)
                    CustomInputHarianCard(
                      key: _inputCardKey,
                      onSubmit: _submitHarian, // <-- Tipe payload sudah diubah
                      submitterName:
                      cage.pic?.name ?? cage.pic?.username ?? '-',
                      onHidden: () {
                        setState(() => _isInputMode = false);
                      },
                    )
                  else
                    _buildInputTrigger(),

                  const SizedBox(height: 16),
                  PopulationStatCard(cage: cage),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SmallStatCard(
                          title: "Sekam digunakan",
                          value: "${cage.sekam ?? 0} kg",
                          asset: "assets/images/ic_sekam.svg",
                          assetScale: 0.16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SmallStatCard(
                          title: "Solar digunakan",
                          value: "${cage.solar ?? 0} L",
                          asset: "assets/images/ic_solar.svg",
                          assetScale: 0.20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  WideStatCard(
                    title: "Konsumsi Pakan",
                    value: "${cage.pakan ?? 0} kg",
                    asset: "assets/images/ic_pakan.svg",
                    assetScale: 0.25,
                  ),
                  const SizedBox(height: 12),
                  WideStatCard(
                    title: "Obat",
                    value: "${cage.obat ?? 0} L",
                    asset: "assets/images/ic_obat.svg",
                    assetScale: 0.22,
                  ),
                  const SizedBox(height: 16),
                  HistorySection(
                    isLoading: _loadingRiwayat,
                    historyItems: _riwayat,
                    onRefresh: () {
                      final id = _detail?.id ?? widget.cage.id;
                      if (id != null && id > 0) {
                        _loadRiwayat(id);
                      }
                    },
                  )
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

  // (Widget _errorView tidak berubah)
  Widget _errorView(String message) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(title: 'Informasi Kandang'),
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