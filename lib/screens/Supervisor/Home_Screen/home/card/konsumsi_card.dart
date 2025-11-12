import 'package:flutter/material.dart';
import 'package:el_ternak_ppl2/services/storage_service.dart';
import '../widget/statcard_gudang.dart';

class InfoKonsumsi extends StatefulWidget {
  const InfoKonsumsi({super.key});

  @override
  State<InfoKonsumsi> createState() => _InfoKonsumsiState();
}

class _InfoKonsumsiState extends State<InfoKonsumsi> {
  final _svc = StorageService();
  int _year = 2025;
  late Future<Map<String, List<num>>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<Map<String, List<num>>> _loadData() async {
    final report = await _svc.getStorageYearlyReport(_year);
    return {
      'pakan': report.series(report.pakan),
      'solar': report.series(report.solar),
      'sekam': report.series(report.sekam),
      'ovk': report.series(report.ovk),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<num>>>(
      future: _futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Gagal memuat data: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final data = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              KonsumsiChartCard(
                title: "Konsumsi Pakan",
                data: data['pakan']!.map((e) => e.toDouble()).toList(),
              ),
              const SizedBox(height: 25),
              KonsumsiChartCard(
                title: "Konsumsi Solar",
                data: data['solar']!.map((e) => e.toDouble()).toList(),
              ),
              const SizedBox(height: 25),
              KonsumsiChartCard(
                title: "Konsumsi Sekam",
                data: data['sekam']!.map((e) => e.toDouble()).toList(),
              ),
              const SizedBox(height: 25),
              KonsumsiChartCard(
                title: "Konsumsi OVK",
                data: data['ovk']!.map((e) => e.toDouble()).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
