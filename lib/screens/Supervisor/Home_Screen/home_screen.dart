// lib/screens/Supervisor/Home_Screen/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:el_ternak_ppl2/login.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Button.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/konsumsi_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/keuangan_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/kandang_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/lumbung_card.dart';
import 'package:el_ternak_ppl2/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  late Future<PakanAlert?> _pakanAlertFuture;

  @override
  void initState() {
    super.initState();
    _pakanAlertFuture = _storageService.getPakanAlert();
  }

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
            children: [
              const SizedBox(height: 10),

              // Saldo Usaha
              const CardSaldoUsaha(),

              const SizedBox(height: 12),

              // ======= ALERT PAKAN BANNER =======
              FutureBuilder<PakanAlert?>(
                future: _pakanAlertFuture,
                builder: (context, snapshot) {
                  // kalau masih loading atau error, gak usah nampilin apa-apa
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  }
                  final alert = snapshot.data;
                  if (alert == null || alert.alert != true) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xff28724E),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            // kamu bisa sesuaikan wording-nya lagi
                            'Persediaan ${alert.item} tersisa ${alert.sisaPakan} Kg. '
                            'Sisa ${alert.sisaHariKeAkhirBulan} hari ke akhir bulan. '
                            'Segera lakukan pengisian ulang!',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // tutup banner secara lokal
                            setState(() {
                              _pakanAlertFuture = Future.value(null);
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Info Lumbung
              const InfoLumbungCard(),
              const SizedBox(height: 20),

              // Info Kandang
              const InfoKandangCard(),
              const SizedBox(height: 10),

              // Info Konsumsi
              const InfoKonsumsi(),
            ],
          ),
        ),
      ),
    );
  }
}
