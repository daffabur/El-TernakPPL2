// lib/screens/Employee/Cage_Management/cage_management_peg.dart

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
    return _service.getForEmployee();
  }

  Future<void> _reload() async {
    setState(() => _future = _loadCages());
    try {
      await _future;
    } catch (_) {}
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
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              final msg = (snap.error ?? '').toString();
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Center(child: Text('Gagal memuat kandang:\n$msg')),
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

            final items = snap.data ?? [];

            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                children: [
                  const Icon(Icons.info_outline, size: 48),
                  const SizedBox(height: 12),
                  Center(child: Text('Belum ada kandang untuk akun ini.')),
                  const SizedBox(height: 12),
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

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final cage = items[i];
                return CustomCardCagePeg(
                  cage: cage,
                  onTap: () async {
                    // ============= AUTO REFRESH FIX =============
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomDetailCagePeg(cage: cage),
                      ),
                    );

                    if (updated == true) {
                      await _reload();
                    }
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
