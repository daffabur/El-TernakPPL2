import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/summary_model.dart';

// agar ke Money Management tetap menampilkan navbar
import 'package:el_ternak_ppl2/base/bottom_nav_bar.dart';

// ⬇️ bottom sheet yang sama dengan di Money Management
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Custom_Bottom_Sheets.dart';

class CardSaldoUsaha extends StatefulWidget {
  const CardSaldoUsaha({super.key});

  @override
  State<CardSaldoUsaha> createState() => _CardSaldoUsahaState();
}

class _CardSaldoUsahaState extends State<CardSaldoUsaha> {
  final _api = ApiService();
  late Future<double> _futureSaldo;

  @override
  void initState() {
    super.initState();
    _futureSaldo = _loadSaldo();
  }

  // Ambil saldo dari /transaksi/summary; fallback ke pemasukan - pengeluaran
  Future<double> _loadSaldo() async {
    try {
      final SummaryModel summary = await _api.getSummary();

      double? pick;
      pick ??= _tryGet(() => (summary as dynamic).saldo);
      pick ??= _tryGet(() => (summary as dynamic).totalSaldo);
      pick ??= _tryGet(() => (summary as dynamic).total_balance);
      pick ??= _tryGet(() => (summary as dynamic).balance);
      pick ??= _tryGet(() => (summary as dynamic).total);

      if (pick != null) return pick;

      final pemasukan = await _api.getTotalAmounByType('pemasukan');
      final pengeluaran = await _api.getTotalAmounByType('pengeluaran');
      return pemasukan - pengeluaran;
    } catch (_) {
      final pemasukan = await _api.getTotalAmounByType('pemasukan');
      final pengeluaran = await _api.getTotalAmounByType('pengeluaran');
      return pemasukan - pengeluaran;
    }
  }

  double? _tryGet(double Function() getter) {
    try {
      final v = getter();
      if (v.isNaN || v.isInfinite) return null;
      return v;
    } catch (_) {
      return null;
    }
  }

  String _rupiah(num v) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(v);
  }

  // ===== buka bottom sheet Add (pakai komponen yang sama dengan MoneyManagement) =====
  Future<void> _openAddSheet() async {
    final bool? isSuccess = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const CustomBottomSheets(),
      ),
    );

    // Kalau sukses tambah transaksi, refresh saldo header ini
    if (isSuccess == true && mounted) {
      setState(() => _futureSaldo = _loadSaldo());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30, bottom: 40, left: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          bottom: BorderSide(color: Color(0xffE0E0E0), width: 1.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Usaha',
            style: GoogleFonts.poppins(
              color: const Color(0xff123524),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // ===== Saldo Dinamis dari API =====
          FutureBuilder<double>(
            future: _futureSaldo,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Row(
                  children: [
                    Text(
                      'Rp …',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff104E3E),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                );
              }
              if (snap.hasError) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Gagal memuat saldo',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _futureSaldo = _loadSaldo()),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                );
              }
              final saldo = snap.data ?? 0.0;
              return Text(
                _rupiah(saldo),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff104E3E),
                ),
              );
            },
          ),

          const SizedBox(height: 35),

          // ===== Aksi =====
          Row(
            children: [
              ElevatedButton(
                onPressed: _openAddSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff123524),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  'Add +',
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
                ),
              ),
              const SizedBox(width: 15),
              OutlinedButton(
                onPressed: () {
                  // arahkan ke BottomNavBar dengan tab Money (index 1)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BottomNavBar(initialIndex: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff123524), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  foregroundColor: const Color(0xff123524),
                ),
                child: Text(
                  'Riwayat',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
