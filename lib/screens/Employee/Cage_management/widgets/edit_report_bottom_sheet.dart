import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:el_ternak_ppl2/services/report_service.dart';
import 'package:google_fonts/google_fonts.dart';

class EditReportBottomSheet extends StatefulWidget {
  final Report report;

  const EditReportBottomSheet({super.key, required this.report});

  @override
  State<EditReportBottomSheet> createState() => _EditReportBottomSheetState();
}

class _EditReportBottomSheetState extends State<EditReportBottomSheet> {

  late TextEditingController _bobotController;
  late TextEditingController _kematianController;
  late TextEditingController _pakanController;

  late int _sekamValue;
  late int _solarValue;
  late int _obatValue;

  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _bobotController = TextEditingController(text: widget.report.bobot.toString());
    _kematianController = TextEditingController(text: widget.report.mati.toString());
    _pakanController = TextEditingController(text: widget.report.pakan.toString());

    _sekamValue = (widget.report.sekam ?? 0);
    _solarValue = (widget.report.solar ?? 0);
    _obatValue = (widget.report.obat ?? 0);
  }

  @override
  void dispose() {
    // Selalu dispose controllers!
    _bobotController.dispose();
    _kematianController.dispose();
    _pakanController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    // 1. Kumpulkan data dari controllers dan state
    final Map<String, dynamic> updatedData = {
      'rata_bobot_ayam': double.tryParse(_bobotController.text) ?? 0.0,
      'kematian_ayam': int.tryParse(_kematianController.text) ?? 0,
      'pakan_used': double.tryParse(_pakanController.text) ?? 0.0, // Backend mungkin perlu double
      'sekam_used': _sekamValue,
      'solar_used': _solarValue,
      'obat_used': _obatValue,
    };

    try {
      // 2. Panggil service untuk mengirim data ke API
      // Gunakan ID laporan dari widget.report.id
      await ReportService().updateReport(widget.report.id, updatedData);

      if (!mounted) return;

      // 3. Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      // 4. Tutup bottom sheet dan kirim 'true' sebagai sinyal sukses
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      // 5. Jika terjadi error, tampilkan notifikasi gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // 6. Selalu pastikan loading state dihentikan
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Helper untuk membuat Number Stepper
  Widget _buildNumberStepper({
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: onDecrement),
              Text(
                value.toString(),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: onIncrement),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isLoading,
      child: Stack(
        children: [
          // Konten utama
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Laporan",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                _buildTextField(
                  controller: _bobotController,
                  label: "Bobot Ayam",
                  suffix: "Kg",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _kematianController,
                  label: "Kematian Ayam",
                  suffix: "Ekor",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _pakanController,
                  label: "Pakan Digunakan",
                  suffix: "Kg",
                ),
                const SizedBox(height: 16),
                _buildNumberStepper(
                  label: "Sekam Digunakan",
                  value: _sekamValue,
                  onDecrement: () => setState(() {
                    if (_sekamValue > 0) _sekamValue--;
                  }),
                  onIncrement: () => setState(() => _sekamValue++),
                ),
                const SizedBox(height: 16),
                _buildNumberStepper(
                  label: "Solar Digunakan",
                  value: _solarValue,
                  onDecrement: () => setState(() {
                    if (_solarValue > 0) _solarValue--;
                  }),
                  onIncrement: () => setState(() => _solarValue++),
                ),
                const SizedBox(height: 16),
                _buildNumberStepper(
                  label: "Obat Digunakan",
                  value: _obatValue,
                  onDecrement: () => setState(() {
                    if (_obatValue > 0) _obatValue--;
                  }),
                  onIncrement: () => setState(() => _obatValue++),
                ),

                const SizedBox(height: 32),

                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Simpan",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context), // Tutup bottom sheet
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppStyles.primaryColor,
                          side: BorderSide(color: AppStyles.primaryColor, width: 1.5),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Batal",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Padding bawah
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
