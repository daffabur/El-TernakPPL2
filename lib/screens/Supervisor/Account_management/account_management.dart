import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Card_Employee.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Search_bar.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/line_md.dart';

class AccountManagement extends StatefulWidget {
  const AccountManagement({super.key});

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {
  final ApiService apiService = ApiService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    // Cukup panggil fungsi refresh sekali di initState
    _refreshUsers();
  }

  // Fungsi untuk refresh data dengan memanggil API lagi
  void _refreshUsers() {
    setState(() {
      _usersFuture = apiService.getAllUsers();
    });
  }

  // Fungsi untuk menampilkan bottom sheet mode TAMBAH
  void _showAddSheet() {
    showModalBottomSheet<bool>( // Tambahkan <bool> untuk menangkap hasil
      context: context,
      isScrollControlled: false, // Sudah benar agar tidak full screen
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const CustomBottomSheets(mode: BottomSheetMode.add),
      ),
    ).then((result) {
      // Hanya refresh jika bottom sheet mengembalikan nilai `true`
      if (result == true) {
        _refreshUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daftar akun telah diperbarui.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // floatingActionButton diletakkan sebagai properti dari Scaffold
    return Scaffold(
      appBar: AppBar(
        // Menggunakan AppBar transparan agar search bar terlihat menyatu
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Menempatkan CustomSearchBar di dalam AppBar agar posisinya benar
        title: const CustomSearchBar(),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          // Logika untuk menampilkan loading, error, atau data kosong
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Menampilkan pesan error yang lebih ramah
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Gagal memuat data: ${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data user.'));
          }

          // Jika data berhasil didapat
          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return CustomCardEmployee(
                user: user,
                // Implementasikan onDataChanged untuk me-refresh data setelah edit/delete
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppStyles.primaryColor,
        child: const Iconify(LineMd.account_add, color: Colors.white),
      ),
      // Posisi FloatingActionButton
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
