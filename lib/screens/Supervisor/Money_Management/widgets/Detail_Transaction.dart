import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/transaction_model.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Mengubah dari StatelessWidget menjadi StatefulWidget
class DetailTransaction extends StatefulWidget {
  final TransactionModel transaction;

  const DetailTransaction({super.key, required this.transaction});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  final ApiService _apiService = ApiService();
  bool _isDeleting = false;

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
        await _apiService.deleteTransaction(widget.transaction.id);

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

  // --- WIDGET BARU: Untuk menampilkan gambar placeholder ---
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

  // --- WIDGET BARU: Logika untuk menampilkan gambar ---
  Widget _buildProofImage(String? buktiUrl) {
    // Cek jika URL valid (bukan null, bukan string kosong, dan bukan string "-")
    final bool hasImage = buktiUrl != null &&
        buktiUrl.isNotEmpty &&
        buktiUrl != "-" &&
        (buktiUrl.startsWith("http://") || buktiUrl.startsWith("https://"));

    if (hasImage) {
      // Jika valid, tampilkan Image.network
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            buktiUrl, // <-- Gunakan URL dari API
            fit: BoxFit.cover,
            // Tampilkan loading indicator saat gambar diunduh
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            // Tampilkan error jika gambar gagal dimuat
            errorBuilder: (context, error, stackTrace) {
              print("Error memuat gambar: $error"); // Tambahkan log
              return _buildNoImageView(message: "Gagal memuat gambar");
            },
          ),
        ),
      );
    } else {
      // Jika tidak ada gambar (null, "-", atau string kosong), tampilkan placeholder
      return _buildNoImageView(
          message: buktiUrl == "-"
              ? "Bukti transaksi tidak diunggah"
              : "Tidak ada bukti transaksi");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedDate = DateFormat(
      'd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(widget.transaction.tanggal);

    final bool isIncome = widget.transaction.jenis == 'pemasukan';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implementasi navigasi ke halaman edit
              print("Tombol Edit ditekan untuk ID: ${widget.transaction.id}");
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
      body: SingleChildScrollView(
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
                    // Tampilkan total nominal
                    Text(
                      currencyFormatter.format(widget.transaction.total),
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isIncome ? AppStyles.primaryColor : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.transaction.nama,
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
              // Detail Tambahan
              _buildDetailRow("Kategori", widget.transaction.kategori),
              _buildDetailRow("Tanggal Transaksi", formattedDate),
              if (widget.transaction.catatan != null &&
                  widget.transaction.catatan!.isNotEmpty &&
                  widget.transaction.catatan! != "-") // <-- Tambah cek "-"
                _buildDetailRow("Catatan", widget.transaction.catatan!),

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
                // --- PERUBAHAN DI SINI ---
                // Ganti Container statis dengan widget dinamis
                child: _buildProofImage(widget.transaction.bukti),
                // --- AKHIR PERUBAHAN ---
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
      ),
    );
  }

  // Widget helper untuk membuat baris detail
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
}