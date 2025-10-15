// lib/screens/Supervisor/Cage_Management/widgets/Custom_Detail_Cage.dart
import 'dart:convert';
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

// ===== tambahan import halaman agar bisa dinavigasi dari bottom bar lokal =====
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home_screen.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/money_management.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/cage_management.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/account_management.dart';
import 'package:iconify_flutter/icons/fluent_mdl2.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:iconify_flutter/icons/heroicons_solid.dart';

class CustomDetailCage extends StatefulWidget {
  final Cage cage;
  final String? overridePic;

  const CustomDetailCage({super.key, required this.cage, this.overridePic});

  @override
  State<CustomDetailCage> createState() => _CustomDetailCageState();
}

class _CustomDetailCageState extends State<CustomDetailCage> {
  final _cageService = CageService();
  final _auth = AuthService();

  Cage? _cage; // detail terkini
  String? _picFromApi; // nama PIC dari response mentah
  bool _loading = true;
  bool _deleting = false;

  // ⚠️ samakan dengan CageService
  static const String _base = 'http://10.0.2.2:11222/api';

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final fresh = await _cageService.getById(widget.cage.id);
      await _fetchPicRaw(widget.cage.id);

      if (!mounted) return;
      setState(() {
        _cage = fresh;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cage = widget.cage;
        _loading = false;
      });
    }
  }

  Future<void> _fetchPicRaw(int id) async {
    try {
      final token = await _auth.getToken();
      if (token == null) return;

      final uri = Uri.parse('$_base/kandang/$id');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode != 200) return;
      final body = jsonDecode(res.body);
      final data = (body is Map<String, dynamic>) ? body['data'] : null;
      if (data is Map<String, dynamic>) {
        final raw =
            (data['Penanggung_jawab'] ??
                    data['penanggung_jawab'] ??
                    data['pic'] ??
                    data['PIC'])
                ?.toString()
                .trim();
        if (raw != null && raw.isNotEmpty) {
          if (!mounted) return;
          setState(() => _picFromApi = raw);
        }
      }
    } catch (_) {
      /* ignore */
    }
  }

  // Mapping status → label & warna
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
    if (status == 'maintenance' ||
        status.contains('maint') ||
        status.contains('perbaikan')) {
      return (
        'Maintenance',
        Colors.orange.shade50,
        Colors.orange,
        Colors.orange,
      );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus kandang: $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  // ==== Bottom bar lokal (tanpa mengubah file navbar) ====
  void _onBottomTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MoneyManagement()),
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CageManagement()),
          (route) => false,
        );
        break;
      case 3:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Chicken'))),
          ),
          (route) => false,
        );
        break;
      case 4:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AccountManagement()),
          (route) => false,
        );
        break;
    }
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required int index,
    required bool selected,
  }) {
    final selectedColor = AppStyles.highlightColor;
    final unselectedColor = AppStyles.highlightColor;
    final selectedBackgroundColor = const Color(0xFF3E7B27);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: () => _onBottomTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(12.0),
          decoration: selected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: selectedBackgroundColor.withOpacity(0.1),
                )
              : const BoxDecoration(),
          child: Iconify(
            icon,
            color: selected ? selectedColor : unselectedColor,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    // tab aktif untuk page ini = 2 (Cage)
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 32),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: MaterialSymbols.home,
              label: 'Home',
              index: 0,
              selected: false,
            ),
            _buildNavItem(
              icon: FluentMdl2.money,
              label: 'Money',
              index: 1,
              selected: false,
            ),
            _buildNavItem(
              icon: Healthicons.animal_chicken,
              label: 'Cage',
              index: 2,
              selected: true,
            ),
            _buildNavItem(
              icon: MaterialSymbols.warehouse_rounded,
              label: 'Chicken',
              index: 3,
              selected: false,
            ),
            _buildNavItem(
              icon: HeroiconsSolid.user_group,
              label: 'User',
              index: 4,
              selected: false,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cage = _cage!;
    final String picText = (_picFromApi?.trim().isNotEmpty == true)
        ? _picFromApi!.trim()
        : ((cage.pic ?? '').trim().isNotEmpty
              ? cage.pic!.trim()
              : ((widget.overridePic ?? '').trim().isNotEmpty
                    ? widget.overridePic!.trim()
                    : '-'));

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
        // (hapus ikon delete di AppBar sesuai permintaan)
      ),

      // Pull-to-refresh supaya status/PIC bisa diperbarui manual
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: PIC + status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
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
                    child: Text(
                      picText,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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

              // Sekam & Solar (placeholder)
              Row(
                children: [
                  Expanded(
                    child: _smallStatCard(
                      title: "Sekam Digunakan",
                      value: "1 Kg",
                      asset: "assets/images/ic_sekam.svg",
                      assetScale: 0.15,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _smallStatCard(
                      title: "Solar Digunakan",
                      value: "20 L",
                      asset: "assets/images/ic_solar.svg",
                      assetScale: 0.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              _wideStatCard(
                title: "Konsumsi Pakan",
                value: "100 Kg",
                asset: "assets/images/ic_pakan.svg",
                assetScale: 0.25,
              ),

              const SizedBox(height: 15),

              _wideStatCard(
                title: "Obat",
                value: "20 L",
                asset: "assets/images/ic_obat.svg",
                assetScale: 0.2,
              ),

              const SizedBox(height: 24),

              // Tombol "Hapus Kandang" (outline merah, rounded pill)
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

      // === bottom bar lokal (mirip navbar) ===
      bottomNavigationBar: _bottomBar(),
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
