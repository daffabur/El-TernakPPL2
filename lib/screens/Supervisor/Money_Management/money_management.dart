import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/transaction_model.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Summary_Card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Transaction_Item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoneyManagement extends StatefulWidget {
  const MoneyManagement({super.key});

  @override
  State<MoneyManagement> createState() => _MoneyManagementState();
}

class _MoneyManagementState extends State<MoneyManagement> {
  // 1. Inisialisasi ApiService dan Future untuk data
  final ApiService _apiService = ApiService();
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    // 2. Panggil fungsi untuk mengambil data saat halaman dimuat
    _loadTransactions();
  }

  // Fungsi untuk memuat atau me-refresh data
  void _loadTransactions() {
    setState(() {
      _transactionsFuture = _apiService.getAllTransactions();
    });
  }

  // 3. Fungsi untuk menampilkan bottom sheet
  void _showAddSheet() {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const CustomBottomSheets(), // Pastikan CustomBottomSheets ada
      ),
    ).then((isSuccess) {
      if (isSuccess == true) {
        _loadTransactions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        // 4. Tambahkan RefreshIndicator agar bisa pull-to-refresh
        onRefresh: () async {
          _loadTransactions();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION (TOTAL SALDO) ---
              Container(
                padding: const EdgeInsets.only(top: 60, bottom: 25, left: 35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)
                  ),
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
                          "Rp.50.000.200", // Data ini nanti bisa dihitung dari hasil API
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Tambah"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppStyles.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _showAddSheet,
                        ),
                      ],
                    ),
                    ClipRRect(
                      child: Image.asset(
                        'assets/images/ic_totalSaldo.png',
                        width: MediaQuery.of(context).size.width * 0.3,
                        fit: BoxFit.fitHeight,
                        height: MediaQuery.of(context).size.width * 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // --- FILTER SECTION ---
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final label in [ "Semua", "Hari ini", "Minggu ini", "Bulanan ini", "Tahun" ])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(label),
                                showCheckmark: false,
                                selected: label == "Semua",
                                selectedColor: AppStyles.highlightColor,
                                backgroundColor: Colors.white,
                                labelStyle: GoogleFonts.poppins(
                                  color: label == "Semua" ? Colors.white : AppStyles.highlightColor,
                                ),
                                side: const BorderSide(color: Colors.grey),
                                onSelected: (_) {},
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- SUMMARY CARDS ---
                    Row(
                      children: const [
                        Expanded(
                          child: SummaryCard(
                            image: "assets/images/ic_income.svg",
                            color: Colors.green,
                            title: "Pemasukan",
                            amount: "Rp 25.000.000",
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            image: "assets/images/ic_outcome.svg",
                            color: Colors.red,
                            title: "Pengeluaran",
                            amount: "Rp 105.000.000",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- TRANSACTION HISTORY ---
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

                    FutureBuilder<List<TransactionModel>>(
                      future: _transactionsFuture,
                      builder: (context, snapshot) {
                        // Saat data sedang dimuat
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Jika terjadi error
                        if (snapshot.hasError) {
                          return Center(child: Text("Terjadi error: ${snapshot.error}"));
                        }

                        // Jika data tidak ada atau kosong
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("Belum ada transaksi."));
                        }

                        // Jika data berhasil dimuat
                        final transactions = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return TransactionItem(
                              transaction: transaction,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
