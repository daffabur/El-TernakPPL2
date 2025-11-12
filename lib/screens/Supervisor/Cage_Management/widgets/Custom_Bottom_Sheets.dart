// lib/screens/Supervisor/Cage_Management/widgets/Custom_Bottom_Sheets.dart
import 'dart:convert';
import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model kandang
import '../models/cage_model.dart';

// Service untuk ambil daftar pegawai (PIC)
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';

// Tambahan: untuk ambil token & fetch data raw kandang (PIC & Status)
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:http/http.dart' as http;

/// Mode Tambah / Edit
enum CageSheetMode { add, edit }

class CustomBottomSheets extends StatefulWidget {
  final CageSheetMode mode;
  final Cage? initial;

  /// Jika diisi, dropdown memakai daftar ini (tanpa fetch API).
  /// (Pada mode ini ID tidak tersedia → `idPenanggungJawab` akan kosong.)
  final List<String>? people;

  const CustomBottomSheets({
    super.key,
    this.mode = CageSheetMode.add,
    this.initial,
    this.people,
  });

  @override
  State<CustomBottomSheets> createState() => _CustomBottomSheetsState();
}

class _CustomBottomSheetsState extends State<CustomBottomSheets> {
  final _formKey = GlobalKey<FormState>();

  final _namaKandangController = TextEditingController();
  final _kapasitasController = TextEditingController();

  // ===== Penanggung Jawab (PIC) =====
  final _api = ApiService();
  final _auth = AuthService();
  List<User> _pegawai = [];
  bool _loadingPegawai = false;
  String? _loadPegawaiError;

  /// ID pegawai terpilih (untuk BE)
  int? _selectedPersonId;

  /// Nama/username terpilih (untuk tampilan & payload UI)
  String? _selectedPersonName;

  /// Bila people manual dipakai
  List<String> _manualPeople = [];

  // ===== Status kandang =====
  // Pair: [label (UI), value (BE)]
  final List<(String label, String value)> _statusOptions = const [
    ('Aktif', 'active'),
    ('Nonaktif', 'inactive'),
  ];
  String _selectedStatusValue = 'active'; // nilai yang dikirim ke BE
  String?
  _statusLabelFromBeIfUnknown; // placeholder jika BE kirim status di luar opsi

  // ⚠️ samakan dengan service BE kamu (dipakai hanya untuk fetch data raw)
  static const String _base = 'http://10.0.2.2:11222/api';

  @override
  void initState() {
    super.initState();

    // Prefill saat edit
    final c = widget.initial;
    if (widget.mode == CageSheetMode.edit && c != null) {
      _namaKandangController.text = c.name;
      _kapasitasController.text = c.capacity.toString();

      // Nama PIC dari object awal (bisa saja masih kosong → nanti difetch)
      final fromBe = (c.pic?.name ?? '').trim();
      _selectedPersonName = fromBe.isEmpty ? null : fromBe;

      // Status dari object awal (nanti bisa dioverride saat fetch raw)
      _selectedStatusValue = _normalizeStatusToValue(c.status);
    }

    // Sumber dropdown PIC
    if (widget.people != null) {
      _manualPeople = List<String>.from(widget.people!);
    } else {
      _fetchPegawai();
    }

    // Jika ada ID kandang → fetch raw (PIC & Status) untuk sinkronisasi
    if (widget.initial?.id != null) {
      _fetchCageRaw(widget.initial!.id);
    }
  }

  // ===== Util & fetchers =====
  String _norm(String? s) =>
      (s ?? '').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

  String _normalizeStatusToValue(String statusRaw) {
    final s = _norm(statusRaw);
    if (s == 'active' || s.contains('aktif')) return 'active';
    if (s == 'inactive' || s.contains('non') || s.contains('inaktif')) {
      return 'inactive';
    }
    // Tidak cocok dengan opsi: tampilkan sebagai placeholder
    _statusLabelFromBeIfUnknown = statusRaw.trim().isEmpty
        ? '—'
        : statusRaw.trim();
    return 'active'; // fallback agar dropdown tetap punya value
  }

  /// Fetch data raw kandang by ID → perbarui PIC & Status berdasarkan BE terbaru
  Future<void> _fetchCageRaw(int id) async {
    try {
      final token = await _auth.getToken();
      if (token == null) return;

      final uri = Uri.parse('$_base/kandang/$id');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode != 200) return;
      final body = jsonDecode(res.body);
      final data = (body is Map<String, dynamic>) ? body['data'] : null;
      if (data is! Map<String, dynamic>) return;

      // ---- PIC (string) ----
      final rawPic =
          (data['Penanggung_jawab'] ??
                  data['penanggung_jawab'] ??
                  data['pic'] ??
                  data['PIC'])
              ?.toString()
              .trim();

      // ---- Status (string) ----
      final rawStatus = (data['Status'] ?? data['status'] ?? '')
          .toString()
          .trim();

      if (!mounted) return;
      setState(() {
        if (rawPic != null && rawPic.isNotEmpty) {
          _selectedPersonName = rawPic;
          // kalau daftar pegawai sudah ada → resolve id
          if (_pegawai.isNotEmpty) _resolveIdFromName();
        }
        if (rawStatus.isNotEmpty) {
          _selectedStatusValue = _normalizeStatusToValue(rawStatus);
        }
      });
    } catch (_) {
      // diam saja
    }
  }

  void _resolveIdFromName() {
    final target = _norm(_selectedPersonName);
    if (target.isEmpty) return;
    for (final u in _pegawai) {
      final cands = <String>[
        _norm(u.name),
        _norm(u.username),
        _norm(u.fullName),
        _norm(u.nama),
      ];
      if (cands.any(
        (cand) =>
            cand == target ||
            (cand.isNotEmpty &&
                (cand.contains(target) || target.contains(cand))),
      )) {
        if (u.id != null) {
          _selectedPersonId = u.id;
          _selectedPersonName =
              (u.name ?? u.username ?? u.fullName ?? u.nama ?? '-').toString();
          break;
        }
      }
    }
  }

  Future<void> _fetchPegawai() async {
    setState(() {
      _loadingPegawai = true;
      _loadPegawaiError = null;
    });

    try {
      final items = await _api.getPegawaiOnly();

      // Filter aktif (jika field ada; kalau tidak ada, default true)
      final filtered = items.where((u) => (u.isActive )).toList();

      if (!mounted) return;
      setState(() {
        _pegawai = filtered.where((u) => u.id != null).toList();
        _loadingPegawai = false;

        // kalau sudah punya nama dari BE, coba resolve ke ID
        if (_selectedPersonName != null && _selectedPersonId == null) {
          _resolveIdFromName();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPegawai = false;
        _loadPegawaiError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _namaKandangController.dispose();
    _kapasitasController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // BE minta array ID -> [idPegawai]
    final List<int> idPenanggungJawab =
        (_selectedPersonId != null && _selectedPersonId! > 0)
        ? <int>[_selectedPersonId!]
        : <int>[]; // kosong → user tidak mengubah PIC

    // label UI untuk status
    final String statusLabel = _statusOptions
        .firstWhere(
          (e) => e.$2 == _selectedStatusValue,
          orElse: () => ('Aktif', 'active'),
        )
        .$1;

    final payload = {
      // Umum
      'name': _namaKandangController.text.trim(),
      'capacity': int.tryParse(_kapasitasController.text) ?? 0,

      // === Dipakai BE ===
      'idPenanggungJawab': idPenanggungJawab,
      'status': _selectedStatusValue, // "active" / "inactive"
      'Status': _selectedStatusValue, // alias
      // === Tambahan untuk UI (opsional di BE) ===
      'pic': _selectedPersonName,
      'penanggung_jawab': _selectedPersonName,
      'status_label': statusLabel,

      // Default non-input (aman buat create/update)
      'population': widget.initial?.population ?? 0,
      'deaths': widget.initial?.deaths ?? 0,
    };

    Navigator.pop(context, payload);
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  widget.mode == CageSheetMode.add
                      ? "Tambah Kandang"
                      : "Edit Kandang",
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nama Kandang
              Text("Nama Kandang", style: textTheme.bodyMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: _namaKandangController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Kandang A1",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 15),

              // Kapasitas
              Text("Kapasitas Kandang", style: textTheme.bodyMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: _kapasitasController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Contoh: 15000",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null) return 'Masukkan angka yang valid';
                  if (n <= 0) return 'Kapasitas harus > 0';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Penanggung Jawab
              Text("Penanggung Jawab", style: textTheme.bodyMedium),
              const SizedBox(height: 6),

              // MODE MANUAL (tanpa ID)
              if (widget.people != null) ...[
                DropdownButtonFormField<String>(
                  value: _manualPeople.contains(_selectedPersonName)
                      ? _selectedPersonName
                      : null,
                  hint: Text(_selectedPersonName ?? "Pilih Penanggung Jawab"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: _manualPeople
                      .map(
                        (name) =>
                            DropdownMenuItem(value: name, child: Text(name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPersonName = value;
                      _selectedPersonId = null; // manual = tak ada ID
                    });
                  },
                  validator: (v) {
                    final ok =
                        (v != null && v.isNotEmpty) ||
                        (_selectedPersonName != null &&
                            _selectedPersonName!.isNotEmpty);
                    return ok ? null : 'Pilih penanggung jawab';
                  },
                ),
                const SizedBox(height: 15),
              ]
              // MODE API (dengan ID)
              else ...[
                if (_loadingPegawai) ...[
                  const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: 12),
                ] else if (_loadPegawaiError != null) ...[
                  Text(
                    'Gagal memuat pegawai: $_loadPegawaiError',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: (_selectedPersonId != null && _selectedPersonId! > 0)
                        ? _selectedPersonId
                        : null,
                    hint: Text(_selectedPersonName ?? 'Pilih Penanggung Jawab'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: const [],
                    onChanged: (val) => setState(() => _selectedPersonId = val),
                    validator: (v) {
                      final ok =
                          (v != null && v > 0) ||
                          (_selectedPersonName != null &&
                              _selectedPersonName!.trim().isNotEmpty);
                      return ok ? null : 'Pilih penanggung jawab';
                    },
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  DropdownButtonFormField<int>(
                    value: (_selectedPersonId != null && _selectedPersonId! > 0)
                        ? _selectedPersonId
                        : null,
                    hint: Text(_selectedPersonName ?? "Pilih Penanggung Jawab"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: _pegawai.map((u) {
                      final display =
                          (u.name ?? u.username ?? u.fullName ?? u.nama ?? '')
                              .toString();
                      return DropdownMenuItem<int>(
                        value: u.id, // nilai = ID (int)
                        child: Text(display.isEmpty ? '-' : display),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedPersonId = val;
                        // sinkronkan nama untuk payload 'pic'
                        final sel = _pegawai.firstWhere(
                          (e) => e.id == val,
                          orElse: () => User(
                            id: -1,
                            username: '-',
                            role: '',
                            isActive: false,
                          ),
                        );
                        _selectedPersonName =
                            (sel.name ??
                                    sel.username ??
                                    sel.fullName ??
                                    sel.nama ??
                                    '-')
                                .toString();
                      });
                    },
                    validator: (v) {
                      final ok =
                          (v != null && v > 0) ||
                          (_selectedPersonName != null &&
                              _selectedPersonName!.trim().isNotEmpty);
                      return ok ? null : 'Pilih penanggung jawab';
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ],

              // Status Kandang
              Text("Status Kandang", style: textTheme.bodyMedium),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _statusOptions.any((e) => e.$2 == _selectedStatusValue)
                    ? _selectedStatusValue
                    : null, // kalau 'maintenance' (di luar opsi), value null → hint dipakai
                hint: Text(
                  _statusOptions
                          .firstWhere(
                            (e) => e.$2 == _selectedStatusValue,
                            orElse: () => ('', ''),
                          )
                          .$1
                          .isNotEmpty
                      ? _statusOptions
                            .firstWhere((e) => e.$2 == _selectedStatusValue)
                            .$1
                      : (_statusLabelFromBeIfUnknown ?? 'Pilih Status'),
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: _statusOptions
                    .map(
                      (opt) => DropdownMenuItem<String>(
                        value: opt.$2, // value untuk BE
                        child: Text(opt.$1), // label UI
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _selectedStatusValue = val;
                    _statusLabelFromBeIfUnknown = null; // bersihkan placeholder
                  });
                },
                validator: (v) =>
                    (v == null && _statusLabelFromBeIfUnknown == null)
                    ? 'Pilih status'
                    : null,
              ),
              const SizedBox(height: 25),

              // Tombol aksi
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
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[300],
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
      ),
    );
  }
}
