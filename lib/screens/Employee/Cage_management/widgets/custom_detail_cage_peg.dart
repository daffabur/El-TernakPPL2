// lib/screens/Employee/Cage_Management/widgets/custom_detail_cage_peg.dart
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Employee/Cage_Management/widgets/custom_input_harian_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDetailCagePeg extends StatefulWidget {
  final Cage cage;
  const CustomDetailCagePeg({super.key, required this.cage});

  @override
  State<CustomDetailCagePeg> createState() => _CustomDetailCagePegState();
}

class _CustomDetailCagePegState extends State<CustomDetailCagePeg> {
  final _service = CageService();
  Cage? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final fresh = await _service.getById(widget.cage.id);
      if (!mounted) return;
      setState(() {
        _detail = fresh;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detail = widget.cage;
        _loading = false;
      });
    }
  }

  // stat kecil
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
                Text(title,
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 15)),
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
                Text(title,
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 15)),
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

  void _submitHarian(Map<String, num> data) {
    // TODO: kirim ke BE sesuai endpoint input harian
    // data['kematian'], data['pakan'], data['solar'], data['sekam'], data['obat']
    // Bisa juga call _load() setelah sukses untuk refresh angka.
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final cage = _detail!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          cage.name,
          style: GoogleFonts.poppins(
            color: AppStyles.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ===== Kartu Input Harian =====
              CustomInputHarianCard(onSubmit: _submitHarian),
              const SizedBox(height: 16),

              // ===== Kartu Populasi =====
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
                          Text("Total Populasi",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 20)),
                          const SizedBox(height: 8),
                          Text("${cage.population}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                              )),
                          Text("Kematian",
                              style:
                                  GoogleFonts.poppins(color: Colors.white)),
                          Text("${cage.deaths}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Sekam & Solar
              Row(
                children: [
                  Expanded(
                    child: _smallStatCard(
                      title: "Sekam digunakan",
                      value: "1 kg",
                      asset: "assets/images/ic_sekam.svg",
                      assetScale: 0.15,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _smallStatCard(
                      title: "Solar digunakan",
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
                value: "100 kg",
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
            ],
          ),
        ),
      ),
    );
  }
}
