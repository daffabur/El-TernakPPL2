import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/widget/statcard_kandang.dart';

class InfoKandangCard extends StatefulWidget {
  const InfoKandangCard({super.key});

  @override
  State<InfoKandangCard> createState() => _InfoKandangCardState();
}

class _InfoKandangCardState extends State<InfoKandangCard> {
  final _svc = CageService();

  late Future<List<Cage>> _listFuture;
  Future<Cage>? _detailFuture;

  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _listFuture = _loadCages();
  }

  Future<List<Cage>> _loadCages() async {
    try {
      final list = await _svc.getAll();
      if (list.isNotEmpty) {
        _detailFuture = _svc.getById(list[_selected].id);
        return list;
      }
      final mine = await _svc.getForEmployee();
      if (mine.isNotEmpty) {
        _detailFuture = _svc.getById(mine[_selected].id);
      }
      return mine;
    } catch (_) {
      final mine = await _svc.getForEmployee();
      if (mine.isNotEmpty) {
        _detailFuture = _svc.getById(mine[_selected].id);
      }
      return mine;
    }
  }

  void _onChangeSelected(int i, List<Cage> cages) {
    setState(() {
      _selected = (i >= 0 && i < cages.length) ? i : 0;
      _detailFuture = _svc.getById(cages[_selected].id);
    });
  }

  String _fmtInt(num n) => NumberFormat.decimalPattern('id_ID').format(n);

  // Potong label agar dropdown tidak overflow (tanpa mengubah StatCardKandang)
  List<String> _shortenNames(List<String> names) {
    return names
        .map((s) => s.length > 12 ? '${s.substring(0, 12)}…' : s)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cage>>(
      future: _listFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _loadingSkeleton(),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Gagal memuat data kandang',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final cages = (snap.data ?? const <Cage>[]);
        if (cages.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Tidak ada data kandang.',
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          );
        }

        if (_selected >= cages.length) _selected = 0;

        final names = List<String>.generate(
          cages.length,
          (i) => cages[i].name.isNotEmpty ? cages[i].name : 'Kandang ${i + 1}',
        );
        final namesShort = _shortenNames(names);

        return FutureBuilder<Cage>(
          future: _detailFuture,
          builder: (context, det) {
            final listPop = cages[_selected].population;
            final listDeaths = cages[_selected].deaths;

            final num population = det.hasData ? det.data!.population : listPop;
            final num deaths = det.hasData ? det.data!.deaths : listDeaths;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: StatCardKandang(
                      title: 'Total Populasi',
                      value: population, // num
                      kandangNames: namesShort,
                      selectedIndex: _selected,
                      onChangeIndex: (i) => _onChangeSelected(i, cages),
                      trailingIcon: Icons.pets,
                      // format tampilannya tetap dilakukan di dalam widget,
                      // kita pastikan kirim num yang benar
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCardKandang(
                      title: 'Total Kematian',
                      value: deaths, // num
                      kandangNames: namesShort,
                      selectedIndex: _selected,
                      onChangeIndex: (i) => _onChangeSelected(i, cages),
                      trailingIcon: Icons.receipt_long_rounded,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _loadingSkeleton() {
    Widget _box() => Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
    return Row(
      children: [
        Expanded(child: _box()),
        const SizedBox(width: 12),
        Expanded(child: _box()),
      ],
    );
  }
}
