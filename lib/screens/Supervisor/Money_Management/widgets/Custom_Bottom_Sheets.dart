import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Digunakan untuk memformat input angka
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Digunakan untuk memformat angka menjadi mata uang

// Enum CageSheetMode tidak digunakan di file ini, bisa dihapus jika tidak ada referensi lain
// enum CageSheetMode { add, edit }

class CustomBottomSheets extends StatefulWidget {
  // Mode tidak digunakan, jadi bisa dihapus jika tidak ada logika khusus untuk edit
  // final CageSheetMode mode;

  const CustomBottomSheets({
    super.key,
    // this.mode = CageSheetMode.add,
  });

  @override
  State<CustomBottomSheets> createState() => _CustomBottomSheetsState();
}

class _CustomBottomSheetsState extends State<CustomBottomSheets> {
  // --- CONTROLLERS ---
  final _namaTransaksiController = TextEditingController();
  final _nominalController = TextEditingController();
  final _jumlahController = TextEditingController(text: "1"); // Mulai dari 1
  final _catatanController = TextEditingController();
  // [FIX] Buat controller untuk Total di sini, bukan di build method
  final _totalController = TextEditingController();

  // --- STATE VARIABLES ---
  String? _selectedKategori;
  String _selectedDate = "7 Agustus 2025"; // Ini masih statis, perlu diganti dengan DatePicker jika ingin dinamis
  bool _isPemasukan = true;

  final List<String> _kategoriList = ["Solar", "Obat", "Pakan", "Gaji", "Penjualan Ayam", "Lainnya"];
  // [FIX] Buat NumberFormat untuk memformat angka ke Rupiah
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // [FIX] Tambahkan listener ke controller nominal dan jumlah
    _nominalController.addListener(_updateTotal);
    _jumlahController.addListener(_updateTotal);
    // [FIX] Hitung total awal saat pertama kali dibuka
    _updateTotal();
  }

  @override
  void dispose() {
    // [FIX] Pastikan semua listener dan controller di-dispose
    _nominalController.removeListener(_updateTotal);
    _jumlahController.removeListener(_updateTotal);

    _namaTransaksiController.dispose();
    _nominalController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    _totalController.dispose(); // Jangan lupa dispose _totalController
    super.dispose();
  }

  // [FIX] Fungsi untuk menghitung dan memperbarui field Total
  void _updateTotal() {
    final double nominal = double.tryParse(_nominalController.text) ?? 0.0;
    final int jumlah = int.tryParse(_jumlahController.text) ?? 1; // Default ke 1 jika tidak valid
    final double total = nominal * jumlah;

    // Format angka menjadi string mata uang dan set ke controller Total
    _totalController.text = currencyFormatter.format(total);
  }

  void _handleSave() {
    // validasi sederhana
    if (_namaTransaksiController.text.isEmpty ||
        _selectedKategori == null ||
        _nominalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama, Kategori, dan Nominal wajib diisi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("Simpan Data Keuangan:");
    print("Jenis: ${_isPemasukan ? "Pemasukan" : "Pengeluaran"}");
    print("Nama Transaksi: ${_namaTransaksiController.text}");
    print("Kategori: $_selectedKategori");
    print("Tanggal: $_selectedDate");
    print("Nominal (input): ${_nominalController.text}");
    print("Jumlah: ${_jumlahController.text}");
    print("Total (terhitung): ${_totalController.text}");
    print("Catatan: ${_catatanController.text}");

    // TODO: Ganti dengan logika API call Anda
    // Navigator.pop(context, true); // Kirim 'true' untuk refresh data
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Penting agar BottomSheet pas dengan konten
          children: [
            Center(
              child: Text(
                "Catat Keuangan",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Toggle Pemasukan / Pengeluaran
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isPemasukan = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      _isPemasukan ? AppStyles.primaryColor : Colors.white,
                      foregroundColor:
                      _isPemasukan ? Colors.white : AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Color(0xFF1C4E3E)),
                      ),
                    ),
                    child: const Text("Pemasukan"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isPemasukan = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      !_isPemasukan ? AppStyles.primaryColor : Colors.white,
                      foregroundColor:
                      !_isPemasukan ? Colors.white : AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Color(0xFF1C4E3E)),
                      ),
                    ),
                    child: const Text("Pengeluaran"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Nama Transaksi
            Text("Nama Transaksi",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _namaTransaksiController,
              decoration: InputDecoration(
                hintText: "cth: Penjualan 100 ekor ayam",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Kategori
            DropdownButtonFormField<String>(
              value: _selectedKategori,
              hint: const Text("Pilih Kategori"),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              items: _kategoriList.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) => setState(() => _selectedKategori = value),
            ),
            const SizedBox(height: 15),

            // Tanggal (Rekomendasi: gunakan DatePicker)
            Text("Tanggal", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: _selectedDate),
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onTap: () {
                // TODO: Implementasi Date Picker untuk memilih tanggal
              },
            ),
            const SizedBox(height: 15),

            // Nominal
            Text("Nominal",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              // [FIX] Hanya izinkan input angka
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "cth: 1500000",
                prefixText: "Rp ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Jumlah
            Text("Jumlah",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      int jumlah = int.tryParse(_jumlahController.text) ?? 1;
                      if (jumlah > 1) { // Batasi minimal 1
                        _jumlahController.text = (jumlah - 1).toString();
                        // _updateTotal() akan ter-trigger oleh listener
                      }
                    },
                  ),
                  Expanded(
                    child: Center(
                      // [FIX] Gunakan TextField agar lebih konsisten
                      child: TextField(
                        controller: _jumlahController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      int jumlah = int.tryParse(_jumlahController.text) ?? 0;
                      _jumlahController.text = (jumlah + 1).toString();
                      // _updateTotal() akan ter-trigger oleh listener
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Catatan
            Text("Catatan",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _catatanController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "cth: Pembelian solar sebanyak 10 liter",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Upload Bukti Transaksi
            ElevatedButton(
              onPressed: () {}, // TODO: Implementasi upload file
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Upload Bukti Transaksi"),
            ),
            const SizedBox(height: 15),

            // Total
            Text("Total",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            // [FIX] Gunakan _totalController yang sudah dibuat
            TextField(
              readOnly: true,
              controller: _totalController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200], // Beri warna beda agar jelas tidak bisa diedit
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600), // Buat teksnya tebal
            ),
            const SizedBox(height: 25),

            // Tombol Simpan & Batal
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Simpan",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Batal",
                        style: TextStyle(color: Colors.black87)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
