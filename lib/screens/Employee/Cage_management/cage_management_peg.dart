import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';

import 'widgets/custom_card_cage_peg.dart';
import 'widgets/custom_detail_cage_peg.dart';

class CageManagementPeg extends StatefulWidget {
  const CageManagementPeg({super.key});

  @override
  State<CageManagementPeg> createState() => _CageManagementPegState();
}

class _CageManagementPegState extends State<CageManagementPeg> {
  final _service = CageService();
  late Future<List<Cage>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadCages();
  }

  Future<List<Cage>> _loadCages() async {
    // Pastikan method servicemu mengembalikan Future<List<Cage>>
    return _service.getForEmployee();
  }

  Future<void> _reload() async {
    setState(() => _future = _loadCages());
    try {
      await _future;
    } catch (_) {
      // biarkan FutureBuilder yang menampilkan error
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black87,
        centerTitle: false,
        title: Text(
          'Informasi Kandang',
          style: GoogleFonts.poppins(
            color: AppStyles.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Cage>>(
          future: _future,
          builder: (context, snap) {
            // ===== Loading =====
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ===== Error =====
            if (snap.hasError) {
              final msg = (snap.error ?? '').toString();
              final lower = msg.toLowerCase();
              final is403 =
                  lower.contains('403') || lower.contains('forbidden');

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 48),
                children: [
                  Icon(
                    is403 ? Icons.lock_outline : Icons.error_outline,
                    size: 48,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      is403
                          ? 'Akses kandang ditolak untuk akun ini.\nHubungi atasan untuk mendapatkan akses.'
                          : 'Gagal memuat kandang:\n$msg',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba lagi'),
                    ),
                  ),
                ],
              );
            }

            final items = snap.data ?? const <Cage>[];

            // ===== Empty =====
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 48),
                children: [
                  Icon(Icons.info_outline, size: 44, color: Colors.grey[500]),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Belum ada kandang untuk akun ini.',
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Muat ulang'),
                    ),
                  ),
                ],
              );
            }

            // ===== List kandang =====
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final cage = items[i];
                return CustomCardCagePeg(
                  cage: cage,
                  onTap: () {
                    // Dorong ke halaman detail (push biasa, bukan replacement)
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => CustomDetailCagePeg(cage: cage),
                            settings: RouteSettings(
                              name: 'emp/cage/detail/${cage.id }',
                            ),
                          ),
                        )
                        .then((_) {
                          if (mounted) _reload(); // refresh setelah kembali
                        });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
