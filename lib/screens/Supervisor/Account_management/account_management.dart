import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/models/user_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Button.dart';
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
  // Future untuk menyimpan hasil fetch data
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data saat widget pertama kali dibuat
    _usersFuture = apiService.getAllUsers();
    _refreshUsers();
  }

  // Fungsi untuk refresh data
  void _refreshUsers() {
    setState(() {
      _usersFuture = apiService.getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          Expanded(
              child: CustomSearchBar()
          )
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 20.0),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }


          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data user.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return CustomCardEmployee(
                user: user,
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: CustomBottomSheets(mode: BottomSheetMode.add),
            ),
          ).then((_) {
            // Setelah bottom sheet ditutup (misalnya setelah menyimpan user baru),
            // panggil _refreshUsers untuk memuat ulang daftar user.
            _refreshUsers();
          });
        },
        backgroundColor: AppStyles.primaryColor,
        child: Iconify(LineMd.account_add, color: Colors.white),

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

    );
  }
}
