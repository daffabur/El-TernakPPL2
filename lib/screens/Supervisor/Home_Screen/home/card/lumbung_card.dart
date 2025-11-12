import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:el_ternak_ppl2/services/storage_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_detail.dart'
    show StorageItem;

// === Model ringan untuk UI
class LumbungItem {
  final String nama;
  final double jumlah;
  final double total;
  final String satuan;
  final int warna;

  LumbungItem({
    required this.nama,
    required this.jumlah,
    required this.total,
    required this.satuan,
    required this.warna,
  });
}

class InfoLumbungCard extends StatefulWidget {
  const InfoLumbungCard({super.key});

  @override
  State<InfoLumbungCard> createState() => _InfoLumbungCardState();
}

class _InfoLumbungCardState extends State<InfoLumbungCard> {
  final _svc = StorageService();

  late Future<List<StorageItem>> _future;

  // === State Detail (null => overview)
  String? _detailKategori;
  Future<List<StorageItem>>? _futureDetail;

  @override
  void initState() {
    super.initState();
    _future = _svc.getLumbungSummary();
  }

  // ====== Ganti layar ke DETAIL (tanpa bottom sheet)
  void _handleTapBubble(String kategori) {
    if (kategori != 'Pakan' && kategori != 'Obat') return;
    setState(() {
      _detailKategori = kategori;
      _futureDetail = (kategori == 'Pakan')
          ? _svc.getPakanDetails()
          : _svc.getOvkDetails();
    });
  }

  void _closeDetail() {
    setState(() {
      _detailKategori = null;
      _futureDetail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDetail = _detailKategori != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header Baru =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isDetail)
                IconButton(
                  onPressed: _closeDetail,
                  icon: const Icon(Icons.arrow_back, color: Color(0xff28724E)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'Kembali',
                ),
              Expanded(
                child: Text(
                  isDetail
                      ? "Info Lumbung • Detail ${_detailKategori!}"
                      : "Info Lumbung",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff28724E),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ===== BODY =====
          if (!isDetail)
            _buildOverview()
          else
            _buildDetailCompact(
              kategori: _detailKategori!,
              future: _futureDetail!,
            ),
        ],
      ),
    );
  }

  // =================== OVERVIEW ===================
  Widget _buildOverview() {
    return FutureBuilder<List<StorageItem>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(
                  "Gagal memuat data lumbung",
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _future = _svc.getLumbungSummary()),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final data = snap.data ?? const <StorageItem>[];
        final items = _mapToLumbungItems(data);

        return Column(
          children: [
            const SizedBox(height: 8),
            _BubbleCluster(items: items, onTapName: _handleTapBubble),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildLegendItem(items[0]),
                        const SizedBox(height: 16),
                        _buildLegendItem(items[2]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40, height: 115),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildLegendItem(items[1]),
                        const SizedBox(height: 16),
                        _buildLegendItem(items[3]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // =================== DETAIL (Compact View) ===================
  Widget _buildDetailCompact({
    required String kategori,
    required Future<List<StorageItem>> future,
  }) {
    final unitFallback = (kategori == 'Pakan') ? 'kg' : 'L';
    final color = _colorFor(kategori);

    return FutureBuilder<List<StorageItem>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  "Gagal memuat detail $kategori",
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _futureDetail = (kategori == 'Pakan')
                          ? _svc.getPakanDetails()
                          : _svc.getOvkDetails();
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Muat Ulang'),
                ),
              ],
            ),
          );
        }

        final list = snap.data ?? const <StorageItem>[];
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Tidak ada data',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, c) {
            const spacing = 10.0;
            const columns = 3;

            final cellWidth = (c.maxWidth - spacing * (columns - 1)) / columns;
            final bubbleSize = cellWidth.clamp(44.0, 56.0);

            double percent(StorageItem it) {
              final t = it.totalStock;
              if (t <= 0) return 0;
              final p = (it.currentStock / t) * 100;
              return p.isFinite ? p.clamp(0, 100) : 0;
            }

            List<Widget> tiles = [];
            for (final it in list) {
              final p = percent(it).toInt();
              final unit = (it.unit.isEmpty) ? unitFallback : it.unit;

              tiles.add(
                SizedBox(
                  width: cellWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: bubbleSize,
                        height: bubbleSize,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.92),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$p%',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        it.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_fmt(it.currentStock)} $unit of ${_fmt(it.totalStock)} $unit',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Wrap(
                  spacing: spacing,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: tiles,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _closeDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff28724E),
                    minimumSize: const Size(140, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: const Text('Selesai (Gabung)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =================== Helper ===================
  List<LumbungItem> _mapToLumbungItems(List<StorageItem> items) {
    double _cur(String name) => (items
        .firstWhere((e) => _eq(e, name), orElse: () => _zero(name))
        .currentStock);
    double _tot(String name) => (items
        .firstWhere((e) => _eq(e, name), orElse: () => _zero(name))
        .totalStock);
    String _unit(String name) =>
        (items.firstWhere((e) => _eq(e, name), orElse: () => _zero(name)).unit);

    return [
      LumbungItem(
        nama: 'Pakan',
        jumlah: _cur('Pakan'),
        total: _tot('Pakan'),
        satuan: 'kg',
        warna: 0xff4CAF50,
      ),
      LumbungItem(
        nama: 'Sekam',
        jumlah: _cur('Sekam'),
        total: _tot('Sekam'),
        satuan: 'kg',
        warna: 0xffF4B266,
      ),
      LumbungItem(
        nama: 'Obat',
        jumlah: _cur('Obat'),
        total: _tot('Obat'),
        satuan: 'L',
        warna: 0xff64B5F6,
      ),
      LumbungItem(
        nama: 'Solar',
        jumlah: _cur('Solar'),
        total: _tot('Solar'),
        satuan: 'L',
        warna: 0xffC4BD00,
      ),
    ];
  }

  bool _eq(StorageItem e, String name) =>
      e.name.toLowerCase() == name.toLowerCase() ||
      e.category.toLowerCase() == name.toLowerCase();

  StorageItem _zero(String name) => StorageItem(
    id: name,
    name: name,
    currentStock: 0,
    totalStock: 1,
    unit: '',
    category: name,
  );

  Color _colorFor(String kategori) {
    switch (kategori) {
      case 'Pakan':
        return const Color(0xff4CAF50);
      case 'Sekam':
        return const Color(0xffF4B266);
      case 'Obat':
        return const Color(0xff64B5F6);
      case 'Solar':
        return const Color(0xffC4BD00);
      default:
        return const Color(0xff64B5F6);
    }
  }

  Widget _buildLegendItem(LumbungItem item) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Color(item.warna),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          "${item.nama}: ${_fmt(item.jumlah)} / ${_fmt(item.total)} ${item.satuan}",
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
        ),
      ),
    ],
  );

  String _fmt(num v) =>
      (v == v.roundToDouble()) ? v.toInt().toString() : v.toStringAsFixed(1);
}

// ===== Cluster 4 bubble utama =====
class _BubbleCluster extends StatelessWidget {
  final List<LumbungItem> items;
  final void Function(String name)? onTapName;

  const _BubbleCluster({required this.items, this.onTapName});

  @override
  Widget build(BuildContext context) {
    LumbungItem _get(String name) =>
        items.firstWhere((e) => e.nama == name, orElse: () => items.first);

    final solar = _get('Solar');
    final pakan = _get('Pakan');
    final sekam = _get('Sekam');
    final obat = _get('Obat');

    double _pct(LumbungItem x) =>
        (x.total <= 0) ? 0 : ((x.jumlah / x.total) * 100).clamp(0, 100);

    double _diam(LumbungItem x) {
      const minD = 72.0;
      const maxD = 132.0;
      return minD + (_pct(x) / 100.0) * (maxD - minD);
    }

    final dTop = _diam(solar);
    final dLeft = _diam(pakan);
    final dRight = _diam(sekam);
    final dBottom = _diam(obat);

    final rTop = dTop / 2;
    final rLeft = dLeft / 2;
    final rRight = dRight / 2;
    final rBottom = dBottom / 2;

    const gap = 18.0;
    const sqrt2 = 1.41421356237;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final centerX = w / 2;
        final topCx = centerX, topCy = rTop + 4;
        final distLeft = rTop + rLeft + gap, distRight = rTop + rRight + gap;
        final leftCx = topCx - distLeft / sqrt2,
            leftCy = topCy + distLeft / sqrt2;
        final rightCx = topCx + distRight / sqrt2,
            rightCy = topCy + distRight / sqrt2;
        double bottomCy = topCy + rTop + rBottom + gap;

        final bottomCx = centerX;
        final totalHeight = (bottomCy + rBottom) - (topCy - rTop) + 12;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              _bubble(topCx, topCy, rTop, solar),
              _bubble(
                leftCx,
                leftCy,
                rLeft,
                pakan,
                onTap: () => onTapName?.call('Pakan'),
              ),
              _bubble(rightCx, rightCy, rRight, sekam),
              _bubble(
                bottomCx,
                bottomCy,
                rBottom,
                obat,
                onTap: () => onTapName?.call('Obat'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bubble(
    double cx,
    double cy,
    double r,
    LumbungItem item, {
    VoidCallback? onTap,
  }) {
    final percent = (item.total <= 0)
        ? 0
        : ((item.jumlah / item.total) * 100).clamp(0, 100);

    final child = Container(
      decoration: BoxDecoration(
        color: Color(item.warna).withOpacity(0.92),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Color(item.warna).withOpacity(0.20),
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
      child: GestureDetector(onTap: onTap, child: child),
    );
  }
}
