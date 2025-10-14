import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomBottomSheets extends StatefulWidget {
  const CustomBottomSheets({super.key});

  @override
  State<CustomBottomSheets> createState() => _CustomBottomSheetsState();
}

class _CustomBottomSheetsState extends State<CustomBottomSheets> {
  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nominalController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();

  final _totalController = TextEditingController();

  // --- STATE VARIABLES ---
  String? _selectedJenis = 'pemasukan';
  String? _selectedKategori;
  DateTime _selectedDate = DateTime.now();
  bool _isPemasukan = true;
  bool _isLoading = false;

  final List<String> _kategoriList = [
    "Solar",
    "Obat",
    "Pakan",
    "Gaji",
    "Penjualan Ayam",
    "Lainnya",
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
    _updateTotal();
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

  @override
  void dispose() {
    _nominalController.removeListener(_updateTotal);
    _jumlahController.removeListener(_updateTotal);

    _namaController.dispose();
    _nominalController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final double nominal = double.tryParse(_nominalController.text) ?? 0.0;
    final int jumlah = int.tryParse(_jumlahController.text) ?? 1;
    final double total = nominal * jumlah;
    _totalController.text = currencyFormatter.format(total);
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final nominal = double.tryParse(_nominalController.text) ?? 0.0;
      final jumlah = int.tryParse(_jumlahController.text) ?? 1;
      final total = nominal * jumlah;

      final Map<String, dynamic> transactionData = {
        "nama": _namaController.text,
        "jenis": _selectedJenis,
        "kategori": _selectedKategori,
        "tanggal": _selectedDate.toIso8601String(),
        "nominal": nominal.toInt(),
        "jumlah": jumlah,
        "catatan": _catatanController.text,
        "bukti_transaksi": "default.jpg",
        "total": total.toInt(),
      };

      try {
        await _apiService.createTransaction(transactionData);
        if (mounted) {
          Navigator.pop(context, true);
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
              content: Text(
                'Error: ${e.toString().replaceAll("Exception: ", "")}',
              ),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isPemasukan = true;
                          _selectedJenis = "pemasukan";
                          _selectedKategori = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPemasukan
                            ? AppStyles.primaryColor
                            : Colors.white,
                        foregroundColor: _isPemasukan
                            ? Colors.white
                            : AppStyles.primaryColor,
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
                      onPressed: () {
                        setState(() {
                          _isPemasukan = false;
                          _selectedJenis = "pengeluaran";
                          _selectedKategori = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isPemasukan
                            ? AppStyles.primaryColor
                            : Colors.white,
                        foregroundColor: !_isPemasukan
                            ? Colors.white
                            : AppStyles.primaryColor,
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
              Text(
                "Nama Transaksi",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: "cth: Penjualan 100 ekor ayam",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama transaksi tidak boleh kosong';
                  }
                  return null;
                },
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

              Text(
                "Tanggal",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat(
                    'd MMMM yyyy',
                    'id_ID',
                  ).format(_selectedDate),
                ),
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onTap: () {
                  _selectDate(context);
                },
              ),
              const SizedBox(height: 15),

              // Nominal
              Text(
                "Nominal",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "cth: 1500000",
                  prefixText: "Rp ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Jumlah
              Text(
                "Jumlah",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
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
                        if (jumlah > 1) {
                          _jumlahController.text = (jumlah - 1).toString();
                        }
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: TextField(
                          controller: _jumlahController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
              Text(
                "Catatan",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
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
              InkWell(
                onTap: () {
                  // TODO: Implementasi logika untuk memilih dan meng-upload file
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upload Bukti Transaksi",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      const Icon(
                        Icons.upload_file_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Total
              Text(
                "Total",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextField(
                readOnly: true,
                controller: _totalController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                      child: const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white),
                      ),
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
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.black87),
                      ),
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
