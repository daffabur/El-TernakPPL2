import 'package:flutter/material.dart';
import '../widget/statcard_gudang.dart';

class InfoKonsumsi extends StatelessWidget {
  const InfoKonsumsi({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          KonsumsiChartCard(
            title: "Konsumsi Pakan",
            data: [7, 5, 6, 4, 8, 6, 7, 6, 7, 9, 8, 5],
          ),
          const SizedBox(height: 25),
          KonsumsiChartCard(
            title: "Konsumsi Solar",
            data: [5, 4, 5, 6, 7, 4, 5, 6, 8, 9, 6, 5],
          ),
          const SizedBox(height: 25),
          KonsumsiChartCard(
            title: "Konsumsi Sekam",
            data: [3, 4, 3, 4, 6, 5, 6, 7, 8, 6, 5, 4],
          ),
          const SizedBox(height: 25),
          KonsumsiChartCard(
            title: "Konsumsi OVK",
            data: [2, 3, 3, 4, 5, 5, 6, 4, 5, 6, 3, 3],
          ),
        ],
      ),
    );
  }
}
