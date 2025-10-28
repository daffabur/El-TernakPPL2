import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StorageManagement extends StatefulWidget {
  const StorageManagement({super.key});

  @override
  State<StorageManagement> createState() => _StorageManagementState();
}

class _StorageManagementState extends State<StorageManagement> {
  final List<Map<String, dynamic>> storageItems = [
    {
      'icon': Icons.grass, // ikon pupuk
      'name': 'Pupuk',
      'current': 70,
      'total': 120,
    },
    {
      'icon': Icons.water_drop, // ikon solar
      'name': 'Solar',
      'current': 50,
      'total': 120,
    },
    {
      'icon': Icons.assignment, // ikon OVK
      'name': 'OVK',
      'current': 50,
      'total': 120,
    },
    {
      'icon': Icons.eco, // ikon sekam
      'name': 'Sekam',
      'current': 80,
      'total': 120,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // === Header ===
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppStyles.primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Informasi Penyimpanan",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // === List Item Penyimpanan ===
              Expanded(
                child: ListView.builder(
                  itemCount: storageItems.length,
                  itemBuilder: (context, index) {
                    final item = storageItems[index];
                    final double progress =
                        item['current'] / item['total'].toDouble();

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 20),
                          padding: const EdgeInsets.only(top: 36, bottom: 48, left: 36, right: 36),
                          decoration: BoxDecoration(
                            color: AppStyles.highlightColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "${item['current']}Kg / ${item['total']}Kg",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 13,
                                  backgroundColor: Colors.white,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      AppStyles.IconCageCardColor),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          top: 0, // Posisi dari atas Stack
                          left: 20, // Posisi dari kiri Stack
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                // Tambahkan bayangan agar ikon lebih menonjol
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4)
                                  )
                                ]
                            ),
                            child: Icon(
                              item['icon'],
                              color: const Color(0xFF2E7D32),
                              size: 32, // Sedikit diperbesar agar lebih terlihat
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
