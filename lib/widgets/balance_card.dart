import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final double income;
  final double expense;

  const BalanceCard({super.key, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Saldo Saat Ini", style: Theme.of(context).textTheme.titleMedium),
            Text(formatter.format(balance), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: balance >= 0 ? Colors.green : Colors.red)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pemasukan"),
                    Text(formatter.format(income), style: const TextStyle(color: Colors.green)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Pengeluaran"),
                    Text(formatter.format(expense), style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
