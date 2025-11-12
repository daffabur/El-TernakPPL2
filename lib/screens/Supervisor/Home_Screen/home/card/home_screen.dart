import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/konsumsi_card.dart';
import 'package:flutter/material.dart';
import 'package:el_ternak_ppl2/login.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Account_management/widgets/Custom_Button.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/keuangan_card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/kandang_card.dart';

import 'package:el_ternak_ppl2/screens/Supervisor/Home_Screen/home/card/lumbung_card.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardSaldoUsaha(),
                const SizedBox(height: 20),
                const InfoLumbungCard(),
                const SizedBox(height: 20),
                const InfoKandangCard(),
                const SizedBox(height: 10),
                const InfoKonsumsi(),
              ],
            ),
          ),
        ),
    );
  }
}