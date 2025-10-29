import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

enum _InputMode { form, success, none }

class CustomInputHarianCard extends StatefulWidget {
  final Future<void> Function(Map<String, num> payload)? onSubmit;

  /// Disediakan agar kompatibel dengan pemanggil lama (tidak dipakai di UI banner-only)
  final String? submitterName;
  final String? submitterAvatarUrl;

  /// Durasi auto-hide banner sukses; set `null` jika tidak ingin auto-hide.
  final Duration? autoHideSuccessAfter;

  /// Callback ke parent bila komponen disembunyikan (auto-hide / tombol X)
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
  final _kematian = TextEditingController();
  final _ratarata = TextEditingController();
  final _pakan = TextEditingController();
  final _solar = TextEditingController();
  final _sekam = TextEditingController();
  final _obat = TextEditingController();

  bool _saving = false;
  _InputMode _mode = _InputMode.form;

  @override
  void dispose() {
    _kematian.dispose();
    _ratarata.dispose();
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

  String _fmtWib(DateTime dt) =>
      DateFormat('HH:mm, dd MMM yyyy', 'id_ID').format(dt.toLocal()) + ' WIB';

  Future<void> _submit() async {
    if (_saving) return;

    final payload = <String, num>{
      'kematian_ayam': num.tryParse(_kematian.text) ?? 0,
      'rata_bobot_ayam': num.tryParse(_ratarata.text) ?? 0,
      'pakan_used': num.tryParse(_pakan.text) ?? 0,
      'solar_used': num.tryParse(_solar.text) ?? 0,
      'sekam_used': num.tryParse(_sekam.text) ?? 0,
      'obat_used': num.tryParse(_obat.text) ?? 0,
    };

    setState(() => _saving = true);
    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(payload);
      }

      if (!mounted) return;

      // Tampilkan banner sukses
      setState(() => _mode = _InputMode.success);

      // Bersihkan field
      _formKey.currentState?.reset();
      _kematian.clear();
      _ratarata.clear();
      _pakan.clear();
      _solar.clear();
      _sekam.clear();
      _obat.clear();

      // Auto-hide: setelah durasi, komponen menghilang (tidak kembali ke form)
      if (widget.autoHideSuccessAfter != null) {
        Future.delayed(widget.autoHideSuccessAfter!, () {
          if (!mounted) return;
          if (_mode == _InputMode.success) {
            setState(() => _mode = _InputMode.none);
            widget.onHidden?.call(); // beri tahu parent
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Banner hijau sederhana (ikon cek – teks – tombol X)
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
              widget.onHidden?.call(); // beri tahu parent
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

  @override
  Widget build(BuildContext context) {
    if (_mode == _InputMode.none) return const SizedBox.shrink();
    if (_mode == _InputMode.success) return _successBannerOnly();

    // === FORM ===
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              TextFormField(
                controller: _pakan,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: _lineInput('Pakan digunakan (kg)'),
              ),
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
              TextFormField(
                controller: _obat,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: _lineInput('Obat digunakan (L)'),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
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
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
