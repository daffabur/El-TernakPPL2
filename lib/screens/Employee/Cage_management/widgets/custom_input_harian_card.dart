// lib/screens/Employee/Cage_Management/widgets/custom_input_harian_card.dart
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInputHarianCard extends StatefulWidget {
  final void Function(Map<String, num> payload)? onSubmit;

  const CustomInputHarianCard({super.key, this.onSubmit});

  @override
  State<CustomInputHarianCard> createState() => _CustomInputHarianCardState();
}

class _CustomInputHarianCardState extends State<CustomInputHarianCard> {
  final _formKey = GlobalKey<FormState>();
  final _kematian = TextEditingController();
  final _pakan = TextEditingController();
  final _solar = TextEditingController();
  final _sekam = TextEditingController();
  final _obat = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _kematian.dispose();
    _pakan.dispose();
    _solar.dispose();
    _sekam.dispose();
    _obat.dispose();
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
      );

  Future<void> _submit() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = <String, num>{
      'kematian': num.tryParse(_kematian.text) ?? 0,
      'pakan': num.tryParse(_pakan.text) ?? 0,
      'solar': num.tryParse(_solar.text) ?? 0,
      'sekam': num.tryParse(_sekam.text) ?? 0,
      'obat': num.tryParse(_obat.text) ?? 0,
    };

    setState(() => _saving = true);
    try {
      // Kirim ke parent (biar bebas: simpan lokal / call API)
      widget.onSubmit?.call(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan harian tersimpan')),
      );

      _formKey.currentState?.reset();
      _kematian.clear();
      _pakan.clear();
      _solar.clear();
      _sekam.clear();
      _obat.clear();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // judul
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
              const SizedBox(height: 14),

              // fields
              TextFormField(
                controller: _kematian,
                keyboardType: TextInputType.number,
                decoration: _lineInput('Kematian ayam'),
              ),
              TextFormField(
                controller: _pakan,
                keyboardType: TextInputType.number,
                decoration: _lineInput('Pakan digunakan'),
              ),
              TextFormField(
                controller: _solar,
                keyboardType: TextInputType.number,
                decoration: _lineInput('Solar digunakan'),
              ),
              TextFormField(
                controller: _sekam,
                keyboardType: TextInputType.number,
                decoration: _lineInput('Sekam digunakan'),
              ),
              TextFormField(
                controller: _obat,
                keyboardType: TextInputType.number,
                decoration: _lineInput('Obat digunakan'),
              ),
              const SizedBox(height: 12),

              // tombol simpan
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.highlightColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                      : Text('Simpan Laporan',
                          style: GoogleFonts.poppins(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
