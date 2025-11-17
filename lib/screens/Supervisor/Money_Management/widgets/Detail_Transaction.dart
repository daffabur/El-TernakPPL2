// lib/screens/Supervisor/Money_Management/detail_transaction.dart

import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/transaction_model.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// Import paket gambar yang sudah kita tambahkan
import 'package:cached_network_image/cached_network_image.dart';

class DetailTransaction extends StatefulWidget {
  final int transactionId; // <-- Terima ID saja

  const DetailTransaction({super.key, required this.transactionId});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;

  // --- 2. BUAT STATE BARU UNTUK FUTURE ---
  late Future<TransactionModel> _transactionFuture;

  @override
  void initState() {
    super.initState();
    // --- 3. PANGGIL API DI initState ---
    // Panggil API detail yang mengembalikan URL gambar
    _transactionFuture = _apiService.getTransactionById(widget.transactionId);
  }

  // (Fungsi _confirmDelete tidak berubah)
  Future<void> _confirmDelete() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );


    if (shouldDelete == true) {
      setState(() => _isDeleting = true);
      try {
        // ID sekarang diambil dari widget.transactionId
        await _apiService.deleteTransaction(widget.transactionId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${e.toString().replaceAll("Exception: ", "")}',
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  // (Widget _buildNoImageView tidak berubah)
  Widget _buildNoImageView({required String message}) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: Colors.grey.shade400, size: 40),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // (Widget _buildProofImage tidak berubah)
  Widget _buildProofImage(String? buktiUrl) {
    final bool hasImage = buktiUrl != null &&
        buktiUrl.isNotEmpty &&
        buktiUrl != "-" &&
        (buktiUrl.startsWith("http://") || buktiUrl.startsWith("https://"));

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          buktiUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,

        ),
      );
    } else {
      return _buildNoImageView(
          message: buktiUrl == "-"
              ? "Bukti transaksi tidak diunggah"
              : "Tidak ada bukti transaksi");
    }
  }

  // (Widget _buildDetailRow tidak berubah)
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[600]),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implementasi navigasi ke halaman edit
              print("Tombol Edit ditekan untuk ID: ${widget.transactionId}");
            },
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      // --- 4. BUNGKUS BODY DENGAN FUTUREBUILDER ---
      body: FutureBuilder<TransactionModel>(
        future: _transactionFuture,
        builder: (context, snapshot) {
          // 4a. Saat Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 4b. Saat Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Gagal memuat detail: ${snapshot.error}"),
              ),
            );
          }

          // 4c. Saat Sukses
          if (!snapshot.hasData) {
            return const Center(child: Text("Data transaksi tidak ditemukan."));
          }

          // --- 5. GUNAKAN DATA 'snapshot.data!' ---
          final transaction = snapshot.data!; // <-- Data LENGKAP dari API Detail

          // (Format helper dipindahkan ke dalam builder)
          final currencyFormatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          final formattedDate = DateFormat(
            'd MMMM yyyy, HH:mm',
            'id_ID',
          ).format(transaction.tanggal);
          final bool isIncome = transaction.jenis == 'pemasukan';

          // --- 6. KEMBALIKAN UI ASLI ANDA ---
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          isIncome ? "Detail Pemasukan" : "Detail Pengeluaran",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppStyles.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(transaction.total),
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isIncome ? AppStyles.primaryColor : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          transaction.nama,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  _buildDetailRow("Kategori", transaction.kategori),
                  _buildDetailRow("Tanggal Transaksi", formattedDate),
                  if (transaction.catatan != null &&
                      transaction.catatan!.isNotEmpty &&
                      transaction.catatan! != "-")
                    _buildDetailRow("Catatan", transaction.catatan!),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    "Bukti Transaksi",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    // Panggil _buildProofImage dengan data yang BENAR
                    child: _buildProofImage(transaction.bukti),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isDeleting ? null : _confirmDelete,
                      child: _isDeleting
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : Text(
                        "Hapus Transaksi",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}