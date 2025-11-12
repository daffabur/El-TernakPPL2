import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bubble_chart/bubble_chart.dart';
import '../models/lumbung_models.dart';

class InfoLumbungCard extends StatelessWidget {
  const InfoLumbungCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Dummy data
    final items = [
      LumbungItem(
        nama: "Pakan",
        jumlah: 750,
        total: 1000,
        satuan: "kg",
        warna: 0xff4CAF50,
      ),
      LumbungItem(
        nama: "Sekam",
        jumlah: 250,
        total: 1000,
        satuan: "kg",
        warna: 0xffF4B266,
      ),
      LumbungItem(
        nama: "Obat",
        jumlah: 500,
        total: 1000,
        satuan: "ml",
        warna: 0xff64B5F6,
      ),
      LumbungItem(
        nama: "Solar",
        jumlah: 700,
        total: 1000,
        satuan: "L",
        warna: 0xffC4BD00,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical:5),
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
          // 🔹 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Info Lumbung",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff28724E),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xff28724E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                ),
                child: Text(
                  "Lihat Laporan",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // 🔹 Bubble Chart Section
          SizedBox(
            height: 250,
            child: BubbleChartLayout(
              duration: const Duration(milliseconds: 1500),
              children: items.map((item) {
                final persentase = (item.jumlah / item.total) * 100;
                return BubbleNode.leaf(
                  value: persentase,
                  options: BubbleOptions(
                    color: Color(item.warna).withOpacity(0.85),
                    child: Text(
                      "${persentase.toInt()}%",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 55),

          // 🔹 Legend Section
          // 🔹 Legend Section (rapih dan sejajar dengan header & bubble)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildLegendItem(items[0]),
                          const SizedBox(height: 20),
                          _buildLegendItem(items[2]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40, height: 115,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildLegendItem(items[1]),
                          const SizedBox(height: 20),
                          _buildLegendItem(items[3]),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(LumbungItem item) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(bottom:15),
          decoration: BoxDecoration(
            color: Color(item.warna),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.nama,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(item.warna),
                ),
              ),
              Text(
                "${item.jumlah} ${item.satuan} of ${item.total} ${item.satuan}",
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
