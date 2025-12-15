import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Storage_Management/models/storage_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStockBottomSheet extends StatefulWidget {
  final StorageItem selectedItem;
  final List<StorageItem> allItemsInCategory;

  const AddStockBottomSheet({
    super.key,
    required this.selectedItem,
    required this.allItemsInCategory,
  });

  @override
  State<AddStockBottomSheet> createState() => _AddStockBottomSheetState();
}

class _AddStockBottomSheetState extends State<AddStockBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _stockController = TextEditingController();
  bool _isLoading = false;

  late String _selectedItemId;
  late String _categoryName;

  @override
  void initState() {
    super.initState();
    _selectedItemId = widget.selectedItem.id;
    _categoryName = widget.selectedItem.category;
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  // Modifikasi _handleSave() untuk simulasi
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // --- Logika Service Diganti Simulasi ---
    try {
      // final double amountToAdd = double.parse(_stockController.text);
      // final String itemId = _selectedItemId;

      // Simulasi panggilan API
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stok berhasil ditambahkan! (Simulasi)"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Kirim 'true' untuk refresh

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
    // --- Akhir Modifikasi ---
  }

  @override
  Widget build(BuildContext context) {
    final String dropdownLabel = "Jenis $_categoryName";

    return IgnorePointer(
      ignoring: _isLoading,
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tambah Stok",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                dropdownLabel,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedItemId,
                isExpanded: true,
                decoration: _inputDecoration(),
                items: widget.allItemsInCategory.map((StorageItem item) {
                  return DropdownMenuItem<String>(
                    value: item.id,
                    child: Text(item.name,
                        style: GoogleFonts.poppins(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedItemId = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              Text(
                "Banyak Stok",
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration:
                _inputDecoration().copyWith(hintText: "Contoh: 15000"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Jumlah tidak boleh kosong";
                  }
                  if (double.tryParse(value) == null) {
                    return "Masukkan angka yang valid";
                  }
                  if (double.parse(value) <= 0) {
                    return "Jumlah harus lebih dari 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Batal",
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppStyles.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _handleSave,
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : Text("Simpan",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
      ),
    );
  }
}