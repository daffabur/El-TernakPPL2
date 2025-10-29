// lib/screens/Supervisor/Account_management/widgets/Custom_Bottom_Sheets.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Cage_Management/models/cage_model.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:el_ternak_ppl2/services/auth_service.dart';
import 'package:el_ternak_ppl2/services/cage_services.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

enum BottomSheetMode { add, edit }

class CustomBottomSheets extends StatefulWidget {
  final BottomSheetMode mode;
  final User? user;

  const CustomBottomSheets({
    super.key,
    this.mode = BottomSheetMode.add,
    this.user,
  }) : assert(
         mode == BottomSheetMode.edit ? user != null : true,
         'User object must be provided in edit mode',
       );

  @override
  State<CustomBottomSheets> createState() => _CustomBottomSheetsState();
}

class _CustomBottomSheetsState extends State<CustomBottomSheets> {
  // ===== Services =====
  final ApiService _apiService = ApiService();
  final AuthService _auth = AuthService();
  final CageService _cageService = CageService();

  // Samakan dengan base URL server kamu
  static const String _base = 'http://ec2-54-169-33-190.ap-southeast-1.compute.amazonaws.com:80/api';

  // ===== Controllers & state =====
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _roleItems = ['pegawai', 'petinggi'];
  final Map<String, bool> _statusItems = const {
    'Active': true,
    'Inactive': false,
  };

  String? _selectedRole;
  bool? _selectedStatusValue;

  // Kandang dropdown
  List<Cage> _allCages = <Cage>[];
  bool _loadingCages = false;
  String? _loadCageError;
  int? _selectedKandangId; // nilai yang dikirim ke BE (kandangID)

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Prefill saat edit
    if (widget.mode == BottomSheetMode.edit) {
      _usernameController.text = widget.user!.username;
      _selectedRole = widget.user!.role;
      _selectedStatusValue = widget.user!.isActive;
      _selectedKandangId = widget.user!.kandangId; // bisa null
    }

    // Default role saat add
    _selectedRole ??= 'pegawai';
    _selectedStatusValue ??= true;

    // Muat list kandang & coba preselect
    _loadCagesAndPreselect();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================================================
  // Helpers HTTP kecil (ambil detail kandang mentah jika perlu PIC)
  // =========================================================
  Future<Map<String, String>> _bearerHeaders() async {
    final t = await _auth.getToken();
    if (t == null) throw Exception('Token tidak ditemukan.');
    final bearer = t.startsWith('Bearer ') ? t : 'Bearer $t';
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': bearer,
    };
  }

  /// Kembalikan nama PIC dari detail kandang, cari berbagai kemungkinan key.
  Future<String?> _getPicFromDetail(int id) async {
    final r = await http.get(
      Uri.parse('$_base/kandang/$id'),
      headers: await _bearerHeaders(),
    );
    if (r.statusCode != 200) return null;
    dynamic body;
    try {
      body = jsonDecode(r.body);
    } catch (_) {}
    final data = (body is Map<String, dynamic>) ? body['data'] : null;
    if (data is! Map<String, dynamic>) return null;

    final v =
        data['Penanggung_jawab'] ??
        data['penanggung_jawab'] ??
        data['PIC'] ??
        data['pic'];
    return v?.toString();
  }

  // =========================================================
  // Load cages & preselect
  // =========================================================
  Future<void> _loadCagesAndPreselect() async {
    setState(() {
      _loadingCages = true;
      _loadCageError = null;
    });

    try {
      final list = await _cageService
          .getAll(); // endpoint admin sudah OK untuk list
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      int? preselectId = _selectedKandangId; // kalau user.kandangId sudah ada

      // Jika belum ada kandang untuk user pegawai → coba cocokkan dari PIC
      if (preselectId == null &&
          (widget.user?.role ?? _selectedRole) == 'pegawai') {
        final u = widget.user?.username.trim().toLowerCase();
        if (u != null && u.isNotEmpty) {
          // 1) Coba cocokkan langsung kalau model list sudah punya field pic
          final fromList = list.firstWhere(
            (c) => (c.pic?.name ?? '').trim().toLowerCase() == u,
            orElse: () => Cage(
              id: -1,
              name: '',
              capacity: 0,
              population: 0,
              deaths: 0,
              pic: null,
              status: '',
              notes: null,
              pakan: 0,
              solar: 0,
              sekam: 0,
              obat: 0,
            ),
          );
          if (fromList.id != -1) {
            preselectId = fromList.id;
          } else {
            // 2) Cek detail per kandang untuk baca Penanggung_jawab dari BE
            for (final c in list) {
              final pic = await _getPicFromDetail(c.id);
              if (pic != null && pic.trim().toLowerCase() == u) {
                preselectId = c.id;
                break;
              }
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _allCages = list;
        _selectedKandangId = preselectId; // akan tampil kalau ketemu
        _loadingCages = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCages = false;
        _loadCageError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // =========================================================
  // Actions
  // =========================================================
  Future<void> _handleDelete() async {
    if (widget.mode != BottomSheetMode.edit) return;

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus user "${widget.user!.username}"?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    setState(() => _isLoading = true);

    try {
      final usernameToDelete = widget.user?.username;
      if (usernameToDelete == null || usernameToDelete.isEmpty) {
        throw Exception('Username user tidak ditemukan untuk dihapus.');
      }
      await _apiService.deleteUser(usernameToDelete);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User berhasil dihapus!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    try {
      int? kandangId;
      if (_selectedRole == 'pegawai' && _selectedKandangId != null) {
        kandangId = _selectedKandangId;
      }

      final userData = <String, dynamic>{
        "username": _usernameController.text.trim(),
        "role": _selectedRole,
        "isActive": _selectedStatusValue,
        if (kandangId != null) "kandangID": kandangId,
      };

      if (widget.mode == BottomSheetMode.add) {
        userData['password'] = _passwordController.text;
        await _apiService.createUser(userData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User berhasil dibuat!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final originalUsername = widget.user?.username;
        if (originalUsername == null || originalUsername.isEmpty) {
          throw Exception("Username asli tidak ditemukan untuk pembaruan.");
        }
        await _apiService.updateUser(originalUsername, userData);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll("Exception: ", "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $msg'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =========================================================
  // UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isLoading,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.mode == BottomSheetMode.edit)
                    GestureDetector(
                      onTap: _isLoading ? null : _handleDelete,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Iconify(
                              MaterialSymbols.delete_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 40),

                  const SizedBox(height: 25),

                  // Username
                  const Text(
                    "Username",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Masukkan username",
                      constraints: const BoxConstraints(maxHeight: 48),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          width: 1.5,
                          color: AppStyles.primaryColor.withOpacity(0.7),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password (add only)
                  if (widget.mode == BottomSheetMode.add) ...[
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Masukkan password",
                        constraints: const BoxConstraints(maxHeight: 48),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: AppStyles.primaryColor.withOpacity(0.7),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Role
                  const Text(
                    "Role",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text("Pilih role"),
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ).copyWith(right: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          width: 1.5,
                          color: AppStyles.primaryColor.withOpacity(0.7),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ),
                    items: _roleItems
                        .map(
                          (v) => DropdownMenuItem<String>(
                            value: v,
                            child: Text(
                              '${v[0].toUpperCase()}${v.substring(1)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedRole = val;
                        // kalau pindah ke petinggi, kosongkan pilihan kandang
                        if (val != 'pegawai') _selectedKandangId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Kandang (hanya untuk pegawai)
                  if (_selectedRole == 'pegawai') ...[
                    const Text(
                      "Kandang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_loadingCages) ...[
                      const LinearProgressIndicator(minHeight: 2),
                      const SizedBox(height: 10),
                    ] else if (_loadCageError != null) ...[
                      Text(
                        'Gagal memuat kandang: $_loadCageError',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _loadCagesAndPreselect,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba lagi'),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      DropdownButtonFormField<int>(
                        value: _selectedKandangId,
                        hint: const Text("Pilih Kandang"),
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 20,
                          ).copyWith(right: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              width: 1.5,
                              color: AppStyles.primaryColor.withOpacity(0.7),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              width: 2.0,
                              color: AppStyles.primaryColor,
                            ),
                          ),
                        ),
                        items: _allCages
                            .map(
                              (c) => DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(
                                  c.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedKandangId = val),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],

                  // Status
                  const Text(
                    "Status",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: _selectedStatusValue,
                    hint: const Text("Pilih Status"),
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ).copyWith(right: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          width: 1.5,
                          color: AppStyles.primaryColor.withOpacity(0.7),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ),
                    items: _statusItems.entries
                        .map(
                          (e) => DropdownMenuItem<bool>(
                            value: e.value,
                            child: Text(
                              e.key,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedStatusValue = v;
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Simpan
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleSave,
                      child: const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
