import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

class CustomBottomSheets extends StatefulWidget {
  const CustomBottomSheets({super.key});

  @override
  State<CustomBottomSheets> createState() => _CustomBottomSheetsState();
}

class _CustomBottomSheetsState extends State<CustomBottomSheets> {
  final List<String> _roleItems = ['Pegawai', 'Atasan'];
  final List<String> _statusItems = ['Active', 'Inactive'];
  String? _selectedRole;
  String? _selectedStatus; // FIX 1: Tambahkan variabel state baru untuk status

  // final _usernameController = TextEditingController();
  // final _passwordController = TextEditingController();
  // final _kandangController = TextEditingController();

  // @override
  // void dispose() {
  //   _usernameController.dispose();
  //   _passwordController.dispose();
  //   _kandangController.dispose();
  //   super.dispose();
  // }

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
              // controller: _usernameController,
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
            const Text(
              "Password",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              // controller: _passwordController,
              obscureText: true,
              style: const TextStyle(fontSize: 16),
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
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
            ),
            const SizedBox(height: 20),


            if (_selectedRole == 'Pegawai')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kandang",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    // controller: _kandangController,
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
            DropdownButtonFormField<String>(
              value: _selectedStatus, // FIX 2: Gunakan _selectedStatus
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
              items: _statusItems.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue; // FIX 3: Perbarui state _selectedStatus
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
                onPressed: () {

                  print("Role: $_selectedRole");
                  print("Status: $_selectedStatus");
                  Navigator.pop(context);
                },
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
