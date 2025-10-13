import 'package:el_ternak_ppl2/screens/Supervisor/Money_Management/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItem({super.key, required this.transaction});

  // Fungsi untuk mendapatkan ikon berdasarkan kategori
  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'solar':
        return Icons.local_gas_station;
      case 'panen':
        return Icons.agriculture;
      case 'gaji':
        return Icons.people;
      case 'pakan':
        return Icons.food_bank_outlined;
      default:
        return Icons.request_quote_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPemasukan = transaction.jenis.toLowerCase() == 'pemasukan';
    final Color amountColor = isPemasukan ? Colors.green : Colors.red;
    final String prefix = isPemasukan ? "+ " : "- ";

    // Format angka ke format mata uang
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final String formattedTotal = currencyFormatter.format(transaction.total);

    // Format tanggal
    final String formattedDate = DateFormat('d MMM yyyy', 'id_ID').format(transaction.tanggal);

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(_getIconForCategory(transaction.kategori), color: Colors.black54),
        ),
        title: Text(transaction.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(formattedDate),
        trailing: Text(
          prefix + formattedTotal,
          style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 15
          ),
        ),
      ),
    );
  }
}
