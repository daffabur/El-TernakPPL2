import 'package:flutter/material.dart';
import 'package:el_ternak_ppl2/login.dart'; // balik ke login
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // dibiarkan ringan (tanpa Scaffold) supaya desain dari BottomNavBar tetap dipakai
    return Center(
      child: CustomButton(
        text: "Log Out",
        backgroundColor: Colors.red, // persis seperti kodingan awalmu
        textColor: Colors.white,
        borderColor: Colors.red,
        onTap: () => _logout(context), // bedanya: ini menjalankan logout
      ),
    );
  }
}
