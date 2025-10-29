import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_model.dart';
import 'package:el_ternak_ppl2/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class StorageManagement extends StatefulWidget {
  const StorageManagement({super.key});

  @override
  State<StorageManagement> createState() => _StorageManagementState();
}

class _StorageManagementState extends State<StorageManagement> {
  final StorageService _storageService = StorageService();
  late Future<Storage> _storageFuture;

  @override
  void initState() {
    super.initState();
    // Inisialisasi locale untuk format tanggal Indonesia
    initializeDateFormatting('id_ID', null);
    _loadStorageData();
  }

  void _loadStorageData() {
    setState(() {
      _storageFuture = _storageService.getStorageData();
    });
  }

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
                child: FutureBuilder<Storage>(
                  future: _storageFuture,
                  builder: (context, snapshot) {
                    // 1. State Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 2. State Error
                    if (snapshot.hasError) {
                      return Center(
                          child: Text("Gagal memuat: ${snapshot.error}"));
                    }

                    // 3. State Data Tidak Ada
                    if (!snapshot.hasData) {
                      return const Center(
                          child: Text("Data penyimpanan tidak ditemukan."));
                    }

                    // 4. State Sukses (Data Tersedia)
                    final storage = snapshot.data!;

                    final List<Map<String, dynamic>> dynamicStorageItems = [
                      {
                        "name": "Pakan",
                        "current": storage.pakanStock,
                        "total": storage.pakanStock + storage.pakanUsed,
                        "icon": Icons.grass,
                        "unit": "Kg"
                      },
                      {
                        "name": "Solar",
                        "current": storage.solarStock,
                        "total": storage.solarStock + storage.solarUsed,
                        "icon": Icons.local_gas_station,
                        "unit": "L"
                      },
                      {
                        "name": "Sekam",
                        "current": storage.sekamStock,
                        "total": storage.sekamStock + storage.sekamUsed,
                        "icon": Icons.layers,
                        "unit": "Kg"
                      },
                      {
                        "name": "Obat",
                        "current": storage.obatStock,
                        "total": storage.obatStock + storage.obatUsed,
                        "icon": Icons.medical_services,
                        "unit": "L"
                      }
                    ];

                    return RefreshIndicator(
                      onRefresh: () async => _loadStorageData(),
                      child: ListView.builder(
                        itemCount: dynamicStorageItems.length,
                        itemBuilder: (context, index) {
                          final item = dynamicStorageItems[index];

                          // Hindari pembagian dengan nol jika totalnya 0
                          final double progress = (item['total'] > 0)
                              ? (item['current'] / item['total'].toDouble())
                              : 0.0;

                          // Tampilkan UI Card Anda dengan data dinamis
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
                                      // Gunakan unit yang sudah kita definisikan
                                      "${item['current']} ${item['unit']} / ${item['total']} ${item['unit']}",
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
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            AppStyles.IconCageCardColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 20,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                            Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4))
                                      ]),
                                  child: Icon(
                                    item['icon'],
                                    color: const Color(0xFF2E7D32),
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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
