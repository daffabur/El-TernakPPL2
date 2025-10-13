import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Summary_Card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Transaction_Item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

class MoneyManagement extends StatefulWidget {
  const MoneyManagement({super.key});

  @override
  State<MoneyManagement> createState() => _MoneyManagementState();
}

class _MoneyManagementState extends State<MoneyManagement> {
  @override
  void _showAddSheet() {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true ,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CustomBottomSheets()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 25, left: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Saldo",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.normal,
                          color: AppStyles.primaryColor,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Rp.50.000.200",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          _showAddSheet();
                        },
                        child: const Text("Add +"),
                      ),
                    ],
                  ),
                  const Iconify(
                    MaterialSymbols.attach_money,
                    color: Color(0xFF1C4E3E),
                    size: 60,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 🟩 Filter Section
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final label in [
                          "Semua",
                          "Hari ini",
                          "Minggu ini",
                          "Bulanan ini",
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(label),
                              showCheckmark: false,
                              selected: label == "Semua",
                              selectedColor: AppStyles.highlightColor,
                              backgroundColor: Colors.white,
                              labelStyle: GoogleFonts.poppins(
                                color: label == "Semua"
                                    ? Colors.white
                                    : AppStyles.highlightColor,
                              ),
                              side: BorderSide(color: Colors.grey),
                              onSelected: (_) {},
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📊 Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          icon: MaterialSymbols.trending_up,
                          color: Colors.green,
                          title: "Pemasukan",
                          amount: "Rp 25.000.000",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          icon: MaterialSymbols.trending_down,
                          color: Colors.red,
                          title: "Pengeluaran",
                          amount: "Rp 105.000.000",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 📜 Transaction History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Histori Transaksi",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppStyles.primaryColor,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: const [
                      TransactionItem(
                        icon: Icons.local_gas_station,
                        title: "Solar",
                        date: "12 April 2025",
                        amount: "- Rp 1.000.000",
                        color: Colors.green,
                      ),
                      TransactionItem(
                        icon: Icons.agriculture,
                        title: "Panen",
                        date: "20 Juni 2025",
                        amount: "Rp 100.000.000",
                        color: Colors.orange,
                      ),
                      TransactionItem(
                        icon: Icons.people,
                        title: "Gaji Karyawan",
                        date: "23 Juni 2025",
                        amount: "- Rp 5.000.000",
                        color: Colors.brown,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
