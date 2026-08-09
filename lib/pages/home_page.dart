import 'package:flutter/material.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_list.dart';
import '../services/db_service.dart';
import '../models/transaction_model.dart';
import 'add_transaction_page.dart';
import 'reports_page.dart';
import 'categories_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TransactionModel> _transactions = [];
  final DbService _db = DbService();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final result = await _db.getAllTransactions();
    setState(() {
      _transactions = result;
    });
  }

  double get totalIncome => _transactions
      .where((tx) => tx.type == 'income')
      .fold(0, (sum, tx) => sum + tx.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == 'expense')
      .fold(0, (sum, tx) => sum + tx.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KasKu")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text("KasKu Menu")),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Kategori"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesPage())),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text("Laporan"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Pengaturan"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: Column(
          children: [
            BalanceCard(
              income: totalIncome,
              expense: totalExpense,
            ),
            Expanded(child: TransactionList(transactions: _transactions)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionPage()));
          _loadTransactions();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
