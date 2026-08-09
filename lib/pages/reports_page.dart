import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text("Laporan")),
      body: _transactions.isEmpty
          ? const Center(child: Text("Belum ada data laporan"))
          : Column(
              children: [
                SizedBox(
                  height: 250,
                  child: SfCircularChart(
                    title: const ChartTitle(text: 'Pengeluaran per Kategori'),
                    series: <CircularSeries<ChartEntry, String>>[
                      CircularSeries<ChartEntry, String>(
                        dataSource: categories.entries.map((e) => ChartEntry(e.key, e.value)).toList(),
                        xValueMapper: (data, _) => data.category,
                        yValueMapper: (data, _) => data.amount,
                        dataLabelMapper: (data, _) => formatter.format(data.amount),
                        name: 'Kategori',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (_, index) {
                      final entry = categories.entries.elementAt(index);
                      final pct = totalExpense > 0 ? (entry.value / totalExpense * 100) : 0;
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.category)),
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

class ChartEntry {
  final String category;
  final double amount;

  ChartEntry(this.category, this.amount);
}
