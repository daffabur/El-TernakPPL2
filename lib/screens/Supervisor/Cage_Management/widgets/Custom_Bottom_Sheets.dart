import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ENUM untuk membedakan mode Tambah atau Edit
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

  final _namaKandangController = TextEditingController();
  final _kapasitasController = TextEditingController();
  final _catatanController = TextEditingController();


  String? _selectedPerson;


  final List<String> _personList = ["Ehsan Bin Mail", "Upin", "Ipin"];

  @override
  void initState() {
    super.initState();

  }


  // 2. Buat fungsi untuk menangani logika saat tombol "Simpan" ditekan
  void _handleSave() {
    // Validasi input sederhana
    if (_namaKandangController.text.isEmpty ||
        _kapasitasController.text.isEmpty ||
        _selectedPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Nama, Kapasitas, dan Penanggung Jawab wajib diisi!')),
      );
      return;
    }


    final namaKandang = _namaKandangController.text;
    final kapasitas = int.tryParse(_kapasitasController.text) ?? 0;
    final penanggungJawab = _selectedPerson;
    final catatan = _catatanController.text;


    print('Data Siap Dikirim ke API:');
    print('Nama: $namaKandang');
    print('Kapasitas: $kapasitas');
    print('PJ: $penanggungJawab');
    print('Catatan: $catatan');
    print('Mode: ${widget.mode}');


    Navigator.pop(context);
  }

  @override
  void dispose() {
    _namaKandangController.dispose();
    _kapasitasController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                // Judul dinamis berdasarkan mode
                widget.mode == CageSheetMode.add
                    ? "Tambah Kandang"
                    : "Edit Kandang",
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),

            // Nama Kandang
            Text("Nama Kandang", style: textTheme.bodyMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _namaKandangController,
              decoration: InputDecoration(
                hintText: "Kandang A1",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 15),

            // Kapasitas Kandang
            Text("Kapasitas Kandang", style: textTheme.bodyMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _kapasitasController, // Kaitkan controller
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Contoh: 15000",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 15),

            // Penanggung Jawab
            Text("Penanggung Jawab", style: textTheme.bodyMedium),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedPerson,
              hint: const Text("Pilih Penanggung Jawab"),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _personList.map((String person) {
                return DropdownMenuItem(value: person, child: Text(person));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPerson = value;
                });
              },
            ),
            const SizedBox(height: 15),

            // Catatan
            Text("Catatan", style: textTheme.bodyMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _catatanController, // Kaitkan controller
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Catatan tambahan (opsional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 25),

            // Tombol Simpan dan Batal
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave, // Panggil fungsi simpan
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Simpan",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Fungsi batal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey[300], // Efek bayangan
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Batal",
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
