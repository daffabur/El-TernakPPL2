// lib/screens/Supervisor/Storage_Management/widgets/storage_detail.dart

import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_detail.dart';
// --- IMPORT SERVICE BARU ---
import 'package:el_ternak_ppl2/services/storage_service.dart';
// ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. UBAH JADI STATEFULWIDGET ---
class StorageDetailScreen extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;

  const StorageDetailScreen({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  State<StorageDetailScreen> createState() => _StorageDetailScreenState();
}

class _StorageDetailScreenState extends State<StorageDetailScreen> {
  // --- 2. TAMBAHKAN STATE UNTUK SERVICE DAN FUTURE ---
  final StorageService _storageService = StorageService();
  late Future<List<StorageItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    // --- 3. PANGGIL API BERDASARKAN KATEGORI ---
    _loadDetails();
  }

  void _loadDetails() {
    setState(() {
      // Tentukan API mana yang harus dipanggil
      if (widget.categoryName == "Pakan") {
        _itemsFuture = _storageService.getPakanDetails();
      } else if (widget.categoryName == "Obat") {
        _itemsFuture = _storageService.getOvkDetails();
      } else {
        // Untuk Solar & Sekam, kita buat data "dummy dinamis"
        // karena mereka tidak punya daftar sub-item
        _itemsFuture = _createFakeList();
      }
    });
  }

  // Fungsi untuk menangani Solar & Sekam (yang tidak punya detail)
  Future<List<StorageItem>> _createFakeList() async {
    // Kita tidak bisa mengambil dari API /storage/ karena butuh data 'used' dan 'total'
    // Untuk saat ini, kita tampilkan saja item tunggal seperti di data dummy Anda
    String unit = "L";
    if (widget.categoryName == "Sekam") unit = "Kg";

    return [
      StorageItem(
        id: widget.categoryName.toLowerCase(),
        name: widget.categoryName,
        // TODO: Data ini seharusnya diambil dari API /storage/
        currentStock: 100,
        totalStock: 200,
        unit: unit,
        category: widget.categoryName,
      ),
    ];
  }


  void _showAddStockSheet(
      BuildContext context, StorageItem item, List<StorageItem> allItems) {
    // TODO: Panggil bottom sheet "Tambah Stok" di sini
    print("Membuka bottom sheet untuk ${item.name}");
  }

  @override
  Widget build(BuildContext context) {
    // --- 4. HAPUS SEMUA BLOK IF/ELSE DUMMY ---

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Informasi ${widget.categoryName}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppStyles.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      // --- 5. GUNAKAN FUTUREBUILDER ---
      body: FutureBuilder<List<StorageItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          // 5a. Saat Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 5b. Saat Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Gagal memuat: ${snapshot.error}", textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loadDetails,
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              ),
            );
          }

          // 5c. Saat Sukses (Data Kosong)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada item ditemukan."));
          }

          // 5d. Saat Sukses (Ada Data)
          final items = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              // Panggil widget kartu yang sudah Anda buat
              return _buildStorageItemCard(context, item, items);
            },
          );
        },
      ),
    );
  }

  // Widget _buildStorageItemCard (Tidak berubah)
  Widget _buildStorageItemCard(
      BuildContext context, StorageItem item, List<StorageItem> allItems) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () => _showAddStockSheet(context, item, allItems),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppStyles.highlightColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.categoryIcon,
                    color: AppStyles.highlightColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  // --- PERBAIKAN KECIL ---
                  // Gunakan data dinamis dari model
                  "${item.currentStock.toStringAsFixed(0)} / ${item.totalStock.toStringAsFixed(0)} ${item.unit}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}