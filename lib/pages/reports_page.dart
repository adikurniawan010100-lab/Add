import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../services/export_service.dart';
import '../models/transaction_model.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<TransactionModel> _transactions = [];
  final DbService _db = DbService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tx = await _db.getAllTransactions();
    setState(() => _transactions = tx);
  }

  Map<String, double> getCategoryTotals() {
    final Map<String, double> totals = {};
    for (var tx in _transactions.where((t) => t.type == 'expense')) {
      totals.update(tx.category, (v) => v + tx.amount, ifAbsent: () => tx.amount);
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final categories = getCategoryTotals();
    final totalExpense = categories.values.fold<double>(0, (sum, val) => sum + val);
    final sortedCats = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text("Laporan")),
      body: _transactions.isEmpty
          ? const Center(child: Text("Belum ada data laporan"))
          : Column(
              children: [
                // Bar chart custom
                SizedBox(
                  height: 220,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: sortedCats.isEmpty
                        ? const SizedBox.shrink()
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: sortedCats.asMap().entries.map((entry) {
                              final cat = entry.value;
                              final maxHeight = sortedCats.first.value;
                              final barHeight = totalExpense > 0 ? (cat.value / maxHeight) * 160 : 0;
                              final pct = totalExpense > 0 ? (cat.value / totalExpense * 100) : 0;
                              return Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(pct.toStringAsFixed(0) + '%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: barHeight,
                                      decoration: BoxDecoration(
                                        color: Colors.primaries[entry.key % Colors.primaries.length],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(cat.key.substring(0, cat.key.length.clamp(0, 4)), style: TextStyle(fontSize: 9)),
                                    Text(formatter.format(cat.value), style: TextStyle(fontSize: 9, color: Colors.grey)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedCats.length,
                    itemBuilder: (_, index) {
                      final entry = sortedCats[index];
                      final pct = totalExpense > 0 ? (entry.value / totalExpense * 100) : 0;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.primaries[index % Colors.primaries.length].withOpacity(0.3),
                          child: const Icon(Icons.category),
                        ),
                        title: Text(entry.key),
                        trailing: Text("${formatter.format(entry.value)} (${pct.toStringAsFixed(1)}%)"),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'csv',
            icon: const Icon(Icons.file_download),
            label: const Text("CSV"),
            onPressed: () async {
              await ExportService.exportToCsv(_transactions, onResult: (msg) {
                if (mounted && msg != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                }
              });
              _load();
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'pdf',
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("PDF"),
            onPressed: () async {
              await ExportService.exportToPdf(_transactions, onResult: (msg) {
                if (mounted && msg != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                }
              });
              _load();
            },
          ),
        ],
      ),
    );
  }
}
