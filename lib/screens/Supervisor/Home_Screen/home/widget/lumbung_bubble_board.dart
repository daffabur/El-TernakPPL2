import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:el_ternak_ppl2/services/storage_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_detail.dart'
    show StorageItem;

/// Item ringkas untuk board (tanpa satuan)
class BubbleSummaryItem {
  final String nama;
  final double jumlah; // current
  final double total; // total
  final int warna; // ARGB

  const BubbleSummaryItem({
    required this.nama,
    required this.jumlah,
    required this.total,
    required this.warna,
  });
}

enum _BoardMode { summary, pakan, ovk }

class LumbungBubbleBoard extends StatefulWidget {
  /// Tinggi area kanvas bubble agar konsisten antara summary & detail.
  final double height;

  final List<BubbleSummaryItem> summary;
  const LumbungBubbleBoard({
    super.key,
    required this.summary,
    this.height = 220,
  });

  @override
  State<LumbungBubbleBoard> createState() => _LumbungBubbleBoardState();
}

class _LumbungBubbleBoardState extends State<LumbungBubbleBoard> {
  final _svc = StorageService();
  _BoardMode _mode = _BoardMode.summary;

  Future<List<StorageItem>>? _pakanF;
  Future<List<StorageItem>>? _ovkF;

  double _pct(double cur, double total) {
    if (total <= 0) return 0;
    final p = (cur / total) * 100;
    return p.isFinite ? p.clamp(0, 100) : 0;
  }

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case _BoardMode.summary:
        return _SummaryBubbles(
          height: widget.height,
          items: widget.summary,
          onTap: (name) {
            if (name == 'Pakan') {
              setState(() {
                _mode = _BoardMode.pakan;
                _pakanF ??= _svc.getPakanDetails();
              });
            } else if (name == 'Obat') {
              setState(() {
                _mode = _BoardMode.ovk;
                _ovkF ??= _svc.getOvkDetails();
              });
            }
          },
        );

      case _BoardMode.pakan:
        return _DetailBubbles(
          height: widget.height,
          title: 'Detail Pakan',
          future: _pakanF ??= _svc.getPakanDetails(),
          theme: const _DetailTheme(
            base: Color(0xff4CAF50), // hijau
            minD: 56,
            maxD: 110,
          ),
          subtitle: (it) =>
              "${it.currentStock.toStringAsFixed(0)} kg of ${it.totalStock.toStringAsFixed(0)} kg",
          percent: (it) => _pct(it.currentStock, it.totalStock),
          onBack: () => setState(() => _mode = _BoardMode.summary),
        );

      case _BoardMode.ovk:
        return _DetailBubbles(
          height: widget.height,
          title: 'Detail OVK / Obat',
          future: _ovkF ??= _svc.getOvkDetails(),
          theme: const _DetailTheme(
            base: Color(0xff64B5F6), // biru
            minD: 56,
            maxD: 110,
          ),
          subtitle: (it) =>
              "${it.currentStock.toStringAsFixed(0)} L of ${it.totalStock.toStringAsFixed(0)} L",
          percent: (it) => _pct(it.currentStock, it.totalStock),
          onBack: () => setState(() => _mode = _BoardMode.summary),
        );
    }
  }
}

/// ======== SUMMARY VIEW (auto-fit ke lebar card) ========
class _SummaryBubbles extends StatelessWidget {
  final double height;
  final List<BubbleSummaryItem> items;
  final void Function(String name)? onTap;
  const _SummaryBubbles({
    required this.items,
    required this.height,
    this.onTap,
  });

  double _pct(double cur, double total) {
    if (total <= 0) return 0;
    final p = (cur / total) * 100;
    return p.isFinite ? p.clamp(0, 100) : 0;
  }

  BubbleSummaryItem _by(String name) =>
      items.firstWhere((e) => e.nama == name, orElse: () => items.first);

  @override
  Widget build(BuildContext context) {
    final pakan = _by('Pakan'); // kiri bawah
    final sekam = _by('Sekam'); // kanan atas
    final obat = _by('Obat'); // kiri atas
    final solar = _by('Solar'); // kecil kanan

    // diameter proporsional, tapi bergantung lebar agar tidak kebesaran
    double diam(BubbleSummaryItem x, double baseW) {
      final maxD = baseW * 0.36; // bound oleh lebar
      final minD = baseW * 0.20;
      return (minD + (_pct(x.jumlah, x.total) / 100.0) * (maxD - minD)).clamp(
        44.0,
        140.0,
      );
    }

    const gap = 18.0; // jarak antar bubble
    const sqrt2 = 1.41421356237;
    const pad = 8.0; // padding aman dari tepi card

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;

          final dSekam = diam(sekam, w);
          final dPakan = diam(pakan, w);
          final dObat = diam(obat, w);
          final dSolar = diam(solar, w) * 0.75; // solar lebih kecil

          double rSekam = dSekam / 2;
          double rPakan = dPakan / 2;
          double rObat = dObat / 2;
          double rSolar = dSolar / 2;

          // Posisi awal (desain)
          double sekamCx = w * 0.56, sekamCy = rSekam + 4;
          double pakanCx = sekamCx - (rSekam + rPakan + gap) / sqrt2;
          double pakanCy = sekamCy + (rSekam + rPakan + gap) / sqrt2;
          double obatCx = pakanCx + (rPakan + rObat + gap) / sqrt2;
          double obatCy = pakanCy - (rPakan + rObat + gap) / sqrt2;
          double solarCx = sekamCx + rSekam + rSolar + gap;
          double solarCy = sekamCy + 4;

          // --- AUTO-FIT: skala jika melebar keluar frame ---
          double minX = [
            sekamCx - rSekam,
            pakanCx - rPakan,
            obatCx - rObat,
            solarCx - rSolar,
          ].reduce(math.min);
          double maxX = [
            sekamCx + rSekam,
            pakanCx + rPakan,
            obatCx + rObat,
            solarCx + rSolar,
          ].reduce(math.max);

          // scale agar muat (biar maxX-minX <= w-2*pad)
          final contentW = maxX - minX;
          final availW = (w - 2 * pad).clamp(40.0, w);
          double scale = contentW > availW ? (availW / contentW) : 1.0;
          if (scale < 1.0) {
            // skala radius & jarak dari centerX supaya layout tetap
            final cx = (minX + maxX) / 2;
            sekamCx = (sekamCx - cx) * scale + cx;
            pakanCx = (pakanCx - cx) * scale + cx;
            obatCx = (obatCx - cx) * scale + cx;
            solarCx = (solarCx - cx) * scale + cx;
            rSekam *= scale;
            rPakan *= scale;
            rObat *= scale;
            rSolar *= scale;
          }

          // shift supaya minX >= pad & maxX <= w - pad
          minX = math.min(
            math.min(sekamCx - rSekam, pakanCx - rPakan),
            math.min(obatCx - rObat, solarCx - rSolar),
          );
          maxX = math.max(
            math.max(sekamCx + rSekam, pakanCx + rPakan),
            math.max(obatCx + rObat, solarCx + rSolar),
          );

          double shiftX = 0;
          if (minX < pad) shiftX = pad - minX;
          if (maxX + shiftX > w - pad) shiftX -= (maxX + shiftX) - (w - pad);

          sekamCx += shiftX;
          pakanCx += shiftX;
          obatCx += shiftX;
          solarCx += shiftX;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              _bubble(sekamCx, sekamCy, rSekam, sekam, tappable: false),
              _bubble(
                pakanCx,
                pakanCy,
                rPakan,
                pakan,
                tappable: true,
                onTap: () => onTap?.call('Pakan'),
              ),
              _bubble(
                obatCx,
                obatCy,
                rObat,
                obat,
                tappable: true,
                onTap: () => onTap?.call('Obat'),
              ),
              _bubble(solarCx, solarCy, rSolar, solar, tappable: false),
            ],
          );
        },
      ),
    );
  }

  Widget _bubble(
    double cx,
    double cy,
    double r,
    BubbleSummaryItem item, {
    required bool tappable,
    VoidCallback? onTap,
  }) {
    final percent = (item.total <= 0)
        ? 0
        : ((item.jumlah / item.total) * 100).clamp(0, 100);

    final content = Container(
      decoration: BoxDecoration(
        color: Color(item.warna).withOpacity(0.94),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Color(item.warna).withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        "${percent.toInt()}%",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );

    return Positioned(
      left: cx - r,
      top: cy - r,
      width: r * 2,
      height: r * 2,
      child: tappable ? GestureDetector(onTap: onTap, child: content) : content,
    );
  }
}

/// ======== DETAIL VIEW (scroll di dalam frame tetap) =========
class _DetailTheme {
  final Color base; // warna utama mode
  final double minD;
  final double maxD;
  const _DetailTheme({
    required this.base,
    required this.minD,
    required this.maxD,
  });
}

class _DetailBubbles extends StatelessWidget {
  final String title;
  final Future<List<StorageItem>> future;
  final _DetailTheme theme;
  final String Function(StorageItem) subtitle;
  final double Function(StorageItem) percent;
  final VoidCallback onBack;
  final double height;

  const _DetailBubbles({
    required this.title,
    required this.future,
    required this.theme,
    required this.subtitle,
    required this.percent,
    required this.onBack,
    required this.height,
  });

  Color _tone(int i) {
    // variasi ringan supaya bubble beda-beda tapi satu tema
    final hsl = HSLColor.fromColor(theme.base);
    final l = (hsl.lightness + (i % 5) * 0.05).clamp(0.35, 0.85).toDouble();
    return hsl.withLightness(l).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left, size: 18),
            label: const Text("Kembali"),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
          ),
        ),
        SizedBox(
          height: height, // << tetap, biar nggak “narik” tinggi card
          child: FutureBuilder<List<StorageItem>>(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    "Gagal memuat data",
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    "Tidak ada data",
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                );
              }

              double diam(StorageItem it) {
                final p = percent(it).clamp(0, 100);
                return theme.minD + (p / 100.0) * (theme.maxD - theme.minD);
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(list.length, (i) {
                    final it = list[i];
                    final d = diam(it);
                    final p = percent(it).clamp(0, 100);
                    final c = _tone(i);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: d,
                          height: d,
                          decoration: BoxDecoration(
                            color: c.withOpacity(0.95),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: c.withOpacity(0.20),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${p.toInt()}%",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 160,
                          child: Text(
                            it.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: Text(
                            subtitle(it),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
