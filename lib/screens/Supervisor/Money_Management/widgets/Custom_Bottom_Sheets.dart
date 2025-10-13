import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CageSheetMode { add, edit }

class CustomBottomSheets extends StatefulWidget {
  final CageSheetMode mode;

  const CustomBottomSheets({
    super.key,
    this.mode = CageSheetMode.add,
  });

  @override
  State<CustomBottomSheets> createState() => _CustomBottomSheetsState();
}

class _CustomBottomSheetsState extends State<CustomBottomSheets> {
  final _namaTransaksiController = TextEditingController();
  final _nominalController = TextEditingController();
  final _jumlahController = TextEditingController(text: "120");
  final _catatanController = TextEditingController();

  String? _selectedKategori;
  String _selectedDate = "7 Agustus 2025";
  bool _isPemasukan = true;

  final List<String> _kategoriList = ["Solar", "Obat", "Pakan"];

  @override
  void dispose() {
    _namaTransaksiController.dispose();
    _nominalController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // validasi sederhana
    if (_namaTransaksiController.text.isEmpty || _selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lengkapi semua data wajib diisi!"),
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
    print("Nominal: ${_nominalController.text}");
    print("Jumlah: ${_jumlahController.text}");
    print("Catatan: ${_catatanController.text}");

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
                      _isPemasukan ? AppStyles.primaryColor: Colors.white,
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
            Text("Nama Transaksi", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _namaTransaksiController,
              decoration: InputDecoration(
                hintText: "Solar",
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

            // Tanggal
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
            ),
            const SizedBox(height: 15),

            // Nominal
            Text("Nominal", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Rp 1.500.000",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Jumlah
            Text("Jumlah", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
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
                      int jumlah = int.tryParse(_jumlahController.text) ?? 0;
                      if (jumlah > 0) {
                        setState(() {
                          _jumlahController.text = (jumlah - 1).toString();
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _jumlahController.text,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      int jumlah = int.tryParse(_jumlahController.text) ?? 0;
                      setState(() {
                        _jumlahController.text = (jumlah + 1).toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Catatan
            Text("Catatan", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _catatanController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "pembelian solar sebanyak 1 liter",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Upload Bukti Transaksi
            ElevatedButton(
              onPressed: () {},
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
            Text("Total", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: "Rp 180.000.000"),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
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
                    child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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
                    child: const Text("Batal", style: TextStyle(color: Colors.black87)),
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
