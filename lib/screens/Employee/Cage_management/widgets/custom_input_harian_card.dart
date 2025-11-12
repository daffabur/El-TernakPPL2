import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/item_stock_model.dart'; // Model Anda
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

enum _InputMode { form, success, none }

enum _InputMode { form, success, none }

class CustomInputHarianCard extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> payload)? onSubmit;
  final String? submitterName;
  final String? submitterAvatarUrl;
  final Duration? autoHideSuccessAfter;
  final VoidCallback? onHidden;

  const CustomInputHarianCard({
    super.key,
    this.onSubmit,
    this.submitterName,
    this.submitterAvatarUrl,
    this.autoHideSuccessAfter = const Duration(seconds: 5),
    this.onHidden,
  });

  @override
  State<CustomInputHarianCard> createState() => _CustomInputHarianCardState();
}

class _CustomInputHarianCardState extends State<CustomInputHarianCard> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _kematian = TextEditingController();
  final _ratarata = TextEditingController();
  final _pakanQty = TextEditingController();
  final _solar = TextEditingController();
  final _sekam = TextEditingController();
  final _obatQty = TextEditingController();

  // Service
  final ApiService _apiService = ApiService();

  // State
  late Future<List<List<ItemStockModel>>> _dropdownDataFuture;
  List<ItemStockModel> _pakanOptions = [];
  List<ItemStockModel> _obatOptions = [];

  String? _selectedPakanName;
  String? _selectedObatName;

  bool _saving = false;
  _InputMode _mode = _InputMode.form;

  @override
  void initState() {
    super.initState();
    _dropdownDataFuture = _loadDropdownData();
  }

  Future<List<List<ItemStockModel>>> _loadDropdownData() async {
    try {
      final results = await Future.wait([
        _apiService.getPakanByType('pakan'),
        _apiService.getOvkByType('ovk'),
      ]);
      if (mounted) {
        setState(() {
          _pakanOptions = results[0];
          _obatOptions = results[1];
        });
      }
      return results;
    } catch (e) {
      print("Gagal memuat data dropdown: $e");
      throw Exception("Gagal memuat opsi: $e");
    }
  }

  @override
  void dispose() {
    _kematian.dispose();
    _ratarata.dispose();
    _pakanQty.dispose();
    _solar.dispose();
    _sekam.dispose();
    _obatQty.dispose();
    super.dispose();
  }

  InputDecoration _lineInput(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black26, width: 1),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppStyles.highlightColor, width: 1.4),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 10),
    isDense: true,
  );

  Future<void> _submit() async {
    if (_saving) return;

    if (_pakanQty.text.isNotEmpty && _selectedPakanName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon pilih jenis pakan")),
      );
      return;
    }
    if (_obatQty.text.isNotEmpty && _selectedObatName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon pilih jenis obat")),
      );
      return;
    }

    // --- PERUBAHAN TIPE PAYLOAD ---
    final payload = <String, dynamic>{
      'kematian_ayam': num.tryParse(_kematian.text) ?? 0,
      'rata_bobot_ayam': num.tryParse(_ratarata.text) ?? 0,
      'pakan_used': num.tryParse(_pakanQty.text) ?? 0,
      'pakan_tipe': _selectedPakanName, // <-- Kirim NAMA (String)
      'solar_used': num.tryParse(_solar.text) ?? 0,
      'sekam_used': num.tryParse(_sekam.text) ?? 0,
      'obat_used': num.tryParse(_obatQty.text) ?? 0,
      'obat_tipe': _selectedObatName, // <-- Kirim NAMA (String)
    };

    setState(() => _saving = true);
    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(payload);
      }
      if (!mounted) return;
      setState(() => _mode = _InputMode.success);

      // Reset form
      _formKey.currentState?.reset();
      _kematian.clear();
      _ratarata.clear();
      _pakanQty.clear();
      _solar.clear();
      _sekam.clear();
      _obatQty.clear();
      setState(() {
        _selectedPakanName = null;
        _selectedObatName = null;
      });

      if (widget.autoHideSuccessAfter != null) {
        Future.delayed(widget.autoHideSuccessAfter!, () {
          if (!mounted) return;
          if (_mode == _InputMode.success) {
            setState(() => _mode = _InputMode.none);
            widget.onHidden?.call();
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // --- REVISI: _buildDropdown sekarang menggunakan String (nama) ---
  Widget _buildDropdown({
    required String hint,
    required List<ItemStockModel> items,
    required String? value, // <-- Diubah ke String
    required ValueChanged<String?> onChanged, // <-- Diubah ke String
  }) {
    return DropdownButtonFormField<String>( // <-- Diubah ke String
      value: value,
      decoration: _lineInput(hint),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black45),
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      items: items.map((item) {
        return DropdownMenuItem<String>( // <-- Diubah ke String
          value: item.nama, // <-- Menggunakan item.nama sebagai VALUE
          child: Text(
            item.nama,
            style: GoogleFonts.poppins(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _successBannerOnly() {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.highlightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check, size: 16, color: AppStyles.highlightColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Terimakasih telah mengerjakan tugas',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _mode = _InputMode.none);
              widget.onHidden?.call();
            },
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Memuat opsi..."),
            ],
          ),
        ));
  }

  Widget _buildErrorView(String error) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 16),
              Text("Gagal memuat: $error", textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _dropdownDataFuture = _loadDropdownData();
                  });
                },
                child: const Text("Coba Lagi"),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == _InputMode.none) return const SizedBox.shrink();
    if (_mode == _InputMode.success) return _successBannerOnly();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: FutureBuilder<List<List<ItemStockModel>>>(
          future: _dropdownDataFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorView(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingView();
            }

            // Form Sukses Dimuat
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26, width: 1.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Input Harian',
                        style: GoogleFonts.poppins(
                          color: AppStyles.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Kematian & Bobot
                  TextFormField(
                    controller: _kematian,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: _lineInput('Kematian ayam (ekor)'),
                  ),
                  TextFormField(
                    controller: _ratarata,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: _lineInput('Rata-rata bobot ayam (kg)'),
                  ),

                  const SizedBox(height: 16),
                  // Section Pakan
                  Text("Pakan",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDropdown(
                          hint: "Pilih Jenis Pakan",
                          items: _pakanOptions,
                          value: _selectedPakanName, // <-- Diubah ke String
                          onChanged: (val) =>
                              setState(() => _selectedPakanName = val), // <-- Diubah ke String
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _pakanQty,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: _lineInput('Jumlah (kg)'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Solar & Sekam
                  TextFormField(
                    controller: _solar,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: _lineInput('Solar digunakan (L)'),
                  ),
                  TextFormField(
                    controller: _sekam,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: _lineInput('Sekam digunakan (kg)'),
                  ),

                  const SizedBox(height: 16),
                  // Section Obat
                  Text("Obat / Vitamin",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDropdown(
                          hint: "Pilih Jenis Obat",
                          items: _obatOptions,
                          value: _selectedObatName, // <-- Diubah ke String
                          onChanged: (val) =>
                              setState(() => _selectedObatName = val), // <-- Diubah ke String
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _obatQty,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: _lineInput('Jumlah (L/ml)'),
                          onFieldSubmitted: (_) => _submit(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tombol Simpan
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.highlightColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        'Simpan Laporan',
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}