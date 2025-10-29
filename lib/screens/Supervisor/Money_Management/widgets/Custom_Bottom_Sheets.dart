import 'dart:io';
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CustomBottomSheets extends StatefulWidget {
  const CustomBottomSheets({super.key});

  @override
  State<CustomBottomSheets> createState() => _CustomBottomSheetsState();
}

class _CustomBottomSheetsState extends State<CustomBottomSheets> {
  // SERVICES & CONTROLLERS
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nominalController = TextEditingController();
  final _jumlahController = TextEditingController(text: '1');
  final _catatanController = TextEditingController();
  final _totalController = TextEditingController();

  // STATE MANAGEMENT
  String _selectedJenis = 'pemasukan';
  String? _selectedKategori;
  DateTime _selectedDate = DateTime.now();
  bool _isPemasukan = true;
  bool _isLoading = false;

  // IMAGE PICKER STATE
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // DATA & FORMATTERS
  final List<String> _kategoriList = [
    "solar",
    "obat",
    "pakan",
    "gaji",
    "panen",
    "penjualan ayam",
    "lainnya",
  ];
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _nominalController.addListener(_updateTotal);
    _jumlahController.addListener(_updateTotal);
    _updateTotal(); // Initialize total on load
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _nominalController.removeListener(_updateTotal);
    _jumlahController.removeListener(_updateTotal);
    _namaController.dispose();
    _nominalController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  // --- METHODS ---

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image to reduce file size
        maxWidth: 1024,   // Resize image to save bandwidth
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      print("Gagal memilih gambar: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Gagal memilih gambar: $e'),
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTotal() {
    final double nominal = double.tryParse(_nominalController.text.replaceAll('.', '')) ?? 0.0;
    final int jumlah = int.tryParse(_jumlahController.text) ?? 1;
    final double total = nominal * jumlah;
    _totalController.text = currencyFormatter.format(total);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSave() async {
    // Validate form fields
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text('Kategori harus dipilih!'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Prepare data
    final double nominal = double.tryParse(_nominalController.text.replaceAll('.', '')) ?? 0.0;
    final int jumlah = int.tryParse(_jumlahController.text) ?? 1;
    final double total = nominal * jumlah;

    // Format date to RFC3339
    String isoDateString = _selectedDate.toIso8601String();
    if (isoDateString.endsWith(".000")) {
      isoDateString = isoDateString.substring(0, isoDateString.length - 4) + "Z";
    } else if (isoDateString.contains(".")) {
      isoDateString = isoDateString.split('.')[0] + "Z";
    }

    // Create data map
    final Map<String, dynamic> transactionData = {
      "nama": _namaController.text,
      "jenis": _selectedJenis,
      "kategori": _selectedKategori!,
      "tanggal": isoDateString,
      "nominal": nominal.toInt(),
      "jumlah": jumlah,
      "total": total.toInt(),
    };

    if (_catatanController.text.trim().isNotEmpty) {
      transactionData['catatan'] = _catatanController.text.trim();
    }

    final String? imagePath = _imageFile?.path;
    print("Data yang dikirim ke API: $transactionData");
    if (imagePath != null) {
      print("Dengan file gambar di path: $imagePath");
    }

    // Call API
    try {
      await _apiService.createTransaction(transactionData, imagePath);

      if (mounted) {
        Navigator.pop(context, true); // Send 'true' to refresh previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Transaksi berhasil ditambahkan!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Gagal: ${e.toString().replaceAll("Exception: ", "")}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- UI BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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

              // Pemasukan / Pengeluaran Toggle
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        _isPemasukan = true;
                        _selectedJenis = "pemasukan";
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPemasukan ? AppStyles.primaryColor : Colors.white,
                        foregroundColor: _isPemasukan ? Colors.white : AppStyles.primaryColor,
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
                      onPressed: () => setState(() {
                        _isPemasukan = false;
                        _selectedJenis = "pengeluaran";
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isPemasukan ? AppStyles.primaryColor : Colors.white,
                        foregroundColor: !_isPemasukan ? Colors.white : AppStyles.primaryColor,
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
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: "cth: Penjualan 100 ekor ayam",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Nama transaksi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 15),

              // Kategori
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                hint: const Text("Pilih Kategori"),
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                items: _kategoriList.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                validator: (value) => value == null ? 'Kategori harus dipilih' : null,
                onChanged: (value) => setState(() => _selectedKategori = value),
              ),
              const SizedBox(height: 15),

              // Tanggal
              Text("Tanggal", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate)),
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 15),

              // Nominal
              Text("Nominal", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "cth: 1500000",
                  prefixText: "Rp ",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Nominal tidak boleh kosong' : null,
              ),
              const SizedBox(height: 15),

              // Jumlah
              Text("Jumlah", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Container(
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
                        if (jumlah > 1) _jumlahController.text = (jumlah - 1).toString();
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _jumlahController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(border: InputBorder.none),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        int jumlah = int.tryParse(_jumlahController.text) ?? 0;
                        _jumlahController.text = (jumlah + 1).toString();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Catatan
              Text("Catatan", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _catatanController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "cth: Pembelian solar sebanyak 10 liter",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),

              // Upload Bukti Transaksi
              Text("Bukti Transaksi (Opsional)", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imageFile == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                      SizedBox(height: 8),
                      Text("Ketuk untuk memilih gambar", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              if (_imageFile != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _imageFile = null),
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: const Text("Hapus Gambar", style: TextStyle(color: Colors.red)),
                  ),
                ),
              const SizedBox(height: 15),

              // Total
              Text("Total", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextFormField(
                readOnly: true,
                controller: _totalController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 25),

              // Tombol Simpan & Batal
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                          : const Text("Simpan", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
      ),
    );
  }
}
