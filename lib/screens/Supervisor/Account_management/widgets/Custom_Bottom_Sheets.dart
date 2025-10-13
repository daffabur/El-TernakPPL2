// D:/CODE/Kuliah/El-TernakPPL2/lib/screens/Supervisor/Account_management/widgets/Custom_Bottom_Sheets.dart

import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
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
  }) : assert(mode == BottomSheetMode.edit ? user != null : true,
  'User object must be provided in edit mode');

  @override
  State<CustomBottomSheets> createState() => _CustomBottomSheetsState();
}

class _CustomBottomSheetsState extends State<CustomBottomSheets> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _kandangController = TextEditingController();

  final List<String> _roleItems = ['pegawai', 'petinggi'];
  final Map<String, bool> _statusItems = {
    'Active': true,
    'Inactive': false,
  };
  String? _selectedRole;
  bool? _selectedStatusValue;

  @override
  void initState() {
    super.initState();
    if (widget.mode == BottomSheetMode.edit) {
      _usernameController.text = widget.user!.username;
      _selectedRole = widget.user!.role;
      _selectedStatusValue = widget.user!.isActive;
      if (widget.user!.role == 'pegawai' && widget.user!.kandangId != null) {
        _kandangController.text = widget.user!.kandangId.toString();
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _kandangController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus user "${widget.user!.username}"?'),
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
        );
      },
    );

    if (confirmDelete != true) return;

    setState(() { _isLoading = true; });

    try {
      final usernameToDelete = widget.user?.username;
      if (usernameToDelete == null || usernameToDelete.isEmpty) {
        throw Exception('Username user tidak ditemukan untuk dihapus.');
      }
      await _apiService.deleteUser(usernameToDelete);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User berhasil dihapus!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $errorMessage'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // --- LOGIKA PEMBUATAN DATA YANG LEBIH AMAN ---
      int? kandangId;
      if (_selectedRole == 'pegawai' && _kandangController.text.isNotEmpty) {
        kandangId = int.tryParse(_kandangController.text);
        if (kandangId == null) {
          throw Exception('ID Kandang harus berupa angka yang valid.');
        }
      }

      final userData = <String, dynamic>{
        "username": _usernameController.text,
        "role": _selectedRole,
        "isActive": _selectedStatusValue,
        if (kandangId != null) "kandangID": kandangId,
      };

      if (widget.mode == BottomSheetMode.add) {
        userData['password'] = _passwordController.text; // Tambahkan password khusus untuk add
        await _apiService.createUser(userData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User berhasil dibuat!'), backgroundColor: Colors.green),
          );
        }
      } else {
        // --- LOGIKA UPDATE ---
        final originalUsername = widget.user?.username;
        if (originalUsername == null || originalUsername.isEmpty) {
          throw Exception("Username asli tidak ditemukan untuk pembaruan.");
        }
        await _apiService.updateUser(originalUsername, userData);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        // --- PENANGANAN ERROR YANG LEBIH BAIK ---
        final errorMessage = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $errorMessage'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

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
                          // --- PERBAIKAN UKURAN TOMBOL ---
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

                  // Sisa kode UI Anda di bawah ini sudah benar.
                  // ...
                  const SizedBox(height: 25),
                  const Text("Username", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Masukkan username",
                      constraints: const BoxConstraints(maxHeight: 48),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(width: 1.5, color: AppStyles.primaryColor.withOpacity(0.7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(width: 2.0, color: AppStyles.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.mode == BottomSheetMode.add)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Masukkan password",
                            constraints: const BoxConstraints(maxHeight: 48),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(width: 1.5, color: AppStyles.primaryColor.withOpacity(0.7)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(width: 2.0, color: AppStyles.primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  const Text("Role", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text("Pilih role"),
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20).copyWith(right: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(width: 1.5, color: AppStyles.primaryColor.withOpacity(0.7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(width: 2.0, color: AppStyles.primaryColor),
                      ),
                    ),
                    items: _roleItems.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('${value[0].toUpperCase()}${value.substring(1)}', style: const TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_selectedRole == 'pegawai')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Kandang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _kandangController,
                          style: const TextStyle(fontSize: 16),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Masukkan ID Kandang",
                            constraints: const BoxConstraints(maxHeight: 48),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(width: 1.5, color: AppStyles.primaryColor.withOpacity(0.7)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(width: 2.0, color: AppStyles.primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  const SizedBox(height: 10),
                  const Text("Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    value: _selectedStatusValue,
                    hint: const Text("Pilih Status"),
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20).copyWith(right: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(width: 1.5, color: AppStyles.primaryColor.withOpacity(0.7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(width: 2.0, color: AppStyles.primaryColor),
                      ),
                    ),
                    items: _statusItems.entries.map((entry) {
                      return DropdownMenuItem<bool>(
                        value: entry.value,
                        child: Text(entry.key, style: const TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                    onChanged: (bool? newValue) {
                      setState(() {
                        _selectedStatusValue = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: _isLoading ? null : _handleSave,
                      child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
