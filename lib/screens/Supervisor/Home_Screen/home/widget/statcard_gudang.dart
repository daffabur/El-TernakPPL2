import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KonsumsiChartCard extends StatefulWidget {
  final String title;
  final List<double> data;
  final Color color;

  const KonsumsiChartCard({
    super.key,
    required this.title,
    required this.data,
    this.color = const Color(0xff28724E),
  });

  @override
  State<KonsumsiChartCard> createState() => _KonsumsiChartCardState();
}

class _KonsumsiChartCardState extends State<KonsumsiChartCard> {
  bool animate = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final rawMax = widget.data.isEmpty
        ? 0.0
        : widget.data.reduce(math.max).toDouble();

    final maxY = rawMax <= 0 ? 1.0 : rawMax * 1.15; // lebih longgar
    const minY = 0.0;

    // SAMA dengan reservedSize bottom axis
    const bottomReserved = 26.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 150,
            child: Stack(
              children: [
                // ===================== CHART =====================
                BarChart(
                  BarChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: bottomReserved,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= months.length) {
                              return const SizedBox();
                            }
                            return Text(
                              months[index],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(enabled: false),
                    barGroups: List.generate(
                      widget.data.length,
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: animate ? widget.data[i] : 0,
                            color: Colors.white,
                            width: 10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ===================== LABEL ANGKA =====================
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final chartWidth = constraints.maxWidth;
                        final chartHeight = constraints.maxHeight;

                        const labelHeight = 16.0;
                        const labelPadding =
                            14.0; // 🔥 di-naikkan biar jauh dari bar

                        final drawingHeight = chartHeight - bottomReserved;

                        final barSpace =
                            chartWidth / widget.data.length.toDouble();

                        return Stack(
                          children: List.generate(widget.data.length, (i) {
                            final v = widget.data[i];
                            if (v <= 0) return const SizedBox.shrink();

                            final t = (v - minY) / (maxY - minY);
                            final barTopY = (1 - t) * drawingHeight;

                            final rawTop = barTopY - labelHeight - labelPadding;

                            final topPos = rawTop.clamp(
                              0.0,
                              chartHeight - labelHeight,
                            );

                            return Positioned(
                              left: barSpace * i,
                              width: barSpace,
                              top: topPos,
                              child: Opacity(
                                opacity: animate ? 1 : 0,
                                child: Center(
                                  child: Text(
                                    v.toStringAsFixed(0),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
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
