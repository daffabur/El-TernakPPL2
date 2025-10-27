import 'package:el_ternak_ppl2/base/res/styles/app_styles.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/transaction_model.dart';
import 'package:el_ternak_ppl2/services/api_service.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Custom_Bottom_Sheets.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Summary_Card.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/widgets/Transaction_Item.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/summary_model.dart';
import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MoneyManagement extends StatefulWidget {
  const MoneyManagement({super.key});

  @override
  State<MoneyManagement> createState() => _MoneyManagementState();
}

class _MoneyManagementState extends State<MoneyManagement> {
  final ApiService _apiService = ApiService();
  late Future<List<TransactionModel>> _transactionsFuture;
  late Future<SummaryModel> _summaryFuture;
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _selectedFilter = "Semua";
  final Map<String, String> _filterMap = {
    "Semua": "",
    "Hari ini": "hari_ini",
    "Minggu ini": "minggu_ini",
    "Bulan ini": "bulan_ini",
  };

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _summaryFuture = _apiService.getSummary();
      final periode = _filterMap[_selectedFilter]!;

      if (periode.isEmpty) {
        _transactionsFuture = _apiService.getAllTransactions();
      } else {
        _transactionsFuture = _apiService.getFilteredTransactions(periode);
      }
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    _loadTransactions();
  }

  void _showAddSheet() {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const CustomBottomSheets(), 
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
        onRefresh: () async {
          _loadTransactions();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 60, bottom: 25, left: 35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
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
                    Expanded(
                      child: Column(
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
                          FutureBuilder<SummaryModel>(
                            future: _summaryFuture,
                            builder: (context, snapshot) {
                              String saldoText = "Memuat...";
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  saldoText = currencyFormatter.format(
                                    snapshot.data!.saldo,
                                  );
                                } else if (snapshot.hasError) {
                                  saldoText = "Error";
                                }
                              }
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  saldoText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppStyles.primaryColor,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            label: const Text("Add"),
                            icon: const Icon(Icons.add, size: 18),
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
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: ClipRRect(
                        child: Image.asset(
                          'assets/images/ic_totalSaldo.png',
                          width: MediaQuery.of(context).size.width * 0.3,
                          fit: BoxFit.contain,
                          height: MediaQuery.of(context).size.width * 0.3,
                        ),
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filterMap.keys.map((label) {
                          final bool isSelected = _selectedFilter == label;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(label),
                              showCheckmark: false,
                              selected: isSelected,
                              selectedColor: AppStyles.highlightColor,
                              backgroundColor: Colors.white,
                              labelStyle: GoogleFonts.poppins(
                                color: isSelected
                                    ? Colors.white
                                    : AppStyles.highlightColor,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppStyles.primaryColor
                                    : Colors.grey.shade400,
                              ),
                              onSelected: (_) {
                                _onFilterSelected(label);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    FutureBuilder<SummaryModel>(
                      future: _summaryFuture,
                      builder: (context, snapshot) {
                        String incomeText = "Memuat...";
                        String outcomeText = "Memuat...";

                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            incomeText = currencyFormatter.format(
                              snapshot.data!.totalPemasukan,
                            );
                            outcomeText = currencyFormatter.format(
                              snapshot.data!.totalPengeluaran,
                            );
                          } else if (snapshot.hasError) {
                            incomeText = "Error";
                            outcomeText = "Error";
                          }
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                image: "assets/images/ic_income.svg",
                                color: Colors.green,
                                title: "Pemasukan",
                                amount: incomeText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SummaryCard(
                                image: "assets/images/ic_outcome.svg",
                                color: Colors.red,
                                title: "Pengeluaran",
                                amount: outcomeText,
                              ),
                            ),
                          ],
                        );
                      },
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Terjadi error: ${snapshot.error}"),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Belum ada transaksi."),
                          );
                        }

                        final transactions = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return TransactionItem(transaction: transaction, onDataChanged: _loadTransactions);
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
