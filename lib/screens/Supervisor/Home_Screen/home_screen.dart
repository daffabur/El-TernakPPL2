import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:el_ternak_ppl2/login.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Button.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/konsumsi_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/keuangan_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/kandang_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/lumbung_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    // (Opsional) hapus token bila disimpan di local storage
    // final prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ==== AppBar fixed di atas, tidak ikut scroll ====
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Dashboard Supervisor",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff28724E),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ==== Body scrollable ====
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 10),
              CardSaldoUsaha(),
              SizedBox(height: 20),
              InfoLumbungCard(),
              SizedBox(height: 20),
              InfoKandangCard(),
              SizedBox(height: 10),
              InfoKonsumsi(),
            ],
          ),
        ),
      ),
    );
  }
}
