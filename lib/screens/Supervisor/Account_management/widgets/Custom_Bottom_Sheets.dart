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
  }): assert(mode == BottomSheetMode.edit ? user != null : true,
  'User object must be provided in edit mode');

  @override
  State<CustomBottomSheets> createState() => _CustomBottomSheetsState();
}

class _CustomBottomSheetsState extends State<CustomBottomSheets> {
  final ApiService _apiService = ApiService(); // Buat instance ApiService
  bool _isLoading = false; // State untuk loading indicator

  // --- CONTROLLERS & VARIABLES ---
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
    // Jika dalam mode edit, isi controllers dan state dari data user yang diberikan
    if (widget.mode == BottomSheetMode.edit) {
      _usernameController.text = widget.user!.username;
      _selectedRole = widget.user!.role;
      _selectedStatusValue = widget.user!.isActive;
      // Anda mungkin juga perlu mengisi kandangID jika ada
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _kandangController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {// ... (kode validasi tidak berubah)

    setState(() {
      _isLoading = true;
    });

    try {
      // PERBAIKAN PADA BAGIAN INI
      Map<String, dynamic> userData = {
        "username": _usernameController.text,
        if (widget.mode == BottomSheetMode.add)
          "password": _passwordController.text,
        "role": _selectedRole,
        "isActive": _selectedStatusValue,
        if (_selectedRole == 'pegawai' && _kandangController.text.isNotEmpty)
          "kandangID": int.tryParse(_kandangController.text)
      };

      // Panggil API Service berdasarkan mode
      if (widget.mode == BottomSheetMode.add) {
        await _apiService.createUser(userData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User berhasil dibuat!'), backgroundColor: Colors.green),
          );
        }
      } else {
        await _apiService.updateUser(widget.user!.username, userData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User berhasil diperbarui!'), backgroundColor: Colors.green),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context); // Tutup bottom sheet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){
                print('Delete button tapped!');
              },
              child: Container (
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Iconify(
                        MaterialSymbols.delete_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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

            // Password
            if (widget.mode == BottomSheetMode.add)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
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

            // Role Dropdown
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
                  child: Text(
                      '${value[0].toUpperCase()}${value.substring(1)}',
                      style: const TextStyle(fontSize: 16)
                  ),
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
                  const Text(
                    "Kandang",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _kandangController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Masukkan nama kandang",
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
                  const SizedBox(height: 5), // Jarak setelah field kandang jika ditampilkan
                ],
              ),

            const SizedBox(height: 10),

            const Text(
              "Status",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<bool>(
              value: _selectedStatusValue, // FIX 2: Gunakan _selectedStatus
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
                  _selectedStatusValue = newValue; // FIX 3: Perbarui state _selectedStatus
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
                        borderRadius: BorderRadius.circular(10)
                    )
                ),
                onPressed: _handleSave,
                child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        )
      ],
    );
  }
}
