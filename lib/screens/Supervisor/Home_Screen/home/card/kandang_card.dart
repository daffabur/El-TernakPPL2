import 'package:flutter/material.dart';
import '../widget/statcard_kandang.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/game_icons.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class InfoKandangCard extends StatelessWidget {
  const InfoKandangCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // card Total Populasi
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                StatCard(
                  title: "Total Populasi",
                  dropdownText: "Kandang 1",
                  value: "8.000",
                  icon: const SizedBox(),
                  color: const Color(0xff28724E),
                ),
                Positioned(
                  bottom: -20,
                  right: -10,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.1416),
                    child: Opacity(
                      opacity: 0.5,
                      child: SizedBox(
                        height: 90,
                        child: Iconify(
                          GameIcons.chicken,
                          size: 75,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // card Total Kematian
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                StatCard(
                  title: "Total Kematian",
                  dropdownText: "Kandang 1",
                  value: "1.000",
                  icon: const SizedBox(),
                  color: const Color(0xff28724E),
                ),
                Positioned(
                  bottom: -10,
                  right: -15,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Opacity(
                      opacity: 0.5,
                      child: SizedBox(
                        height: 75,
                        child: Iconify(
                          Mdi.grave_stone,
                          size: 90,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}