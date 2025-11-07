import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_detail.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/widgets/addStockBottomSheets.dart';// import 'package:el_ternak_ppl2/services/storage_service.dart'; // <-- Dihapus
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  void _showAddStockSheet(
      BuildContext context, StorageItem item, List<StorageItem> allItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: AddStockBottomSheet(
            selectedItem: item,
            allItemsInCategory: allItems,
          ),
        );
      },
    ).then((isSuccess) {
      if (isSuccess == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Simulasi refresh data...")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<StorageItem> items;
    if (widget.categoryName == "Pakan") {
      items = [
        StorageItem(
            id: "p1",
            name: "201C TT G",
            currentStock: 160,
            totalStock: 300,
            unit: "Kg",
            category: "Pakan"),
        StorageItem(
            id: "p2",
            name: "TBR 01",
            currentStock: 200,
            totalStock: 300,
            unit: "Kg",
            category: "Pakan"),
        StorageItem(
            id: "p3",
            name: "BR12WD",
            currentStock: 200,
            totalStock: 300,
            unit: "Kg",
            category: "Pakan"),
      ];
    } else if (widget.categoryName == "Obat") {
      items = [
        StorageItem(
            id: "o1",
            name: "201C TT G", // Contoh dari screenshot
            currentStock: 160,
            totalStock: 290,
            unit: "Kg",
            category: "Obat"),
        StorageItem(
            id: "o2",
            name: "OVK Lain",
            currentStock: 100,
            totalStock: 200,
            unit: "L",
            category: "Obat"),
      ];
    } else if (widget.categoryName == "Solar") {
      items = [
        StorageItem(
            id: "s1",
            name: "Solar",
            currentStock: 100,
            totalStock: 200,
            unit: "L",
            category: "Solar"),
      ];
    } else if (widget.categoryName == "Sekam") {
      items = [
        StorageItem(
            id: "sk1",
            name: "Sekam",
            currentStock: 100,
            totalStock: 200,
            unit: "Kg",
            category: "Sekam"),
      ];
    } else {
      items = []; // Kategori tidak dikenal
    }
    // --- AKHIR DATA CONTOH ---

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
      // FutureBuilder dan RefreshIndicator dihapus, diganti ListView.builder langsung
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Ini adalah kartu item individual di dalam daftar
          return _buildStorageItemCard(context, item, items);
        },
      ),
    );
  }

  // Widget _buildStorageItemCard (Tidak berubah, sudah benar)
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