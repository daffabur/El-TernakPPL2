import 'package:flutter/material.dart';
import 'package:lat_mobile/screens/home/card/lumbung_card.dart';
import '../card/keuangan_card.dart';
import '../card/kandang_card.dart';
import '../card/konsumsiChart_card.dart';

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
