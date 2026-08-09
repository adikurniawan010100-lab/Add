import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_list.dart';
import '../services/db_service.dart';
import '../models/transaction_model.dart';
import 'add_transaction_page.dart';
import 'reports_page.dart';
import 'categories_page.dart';
import 'settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'id_ID';
  runApp(const KasKuApp());
}

class KasKuApp extends StatelessWidget {
  const KasKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KasKu',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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

  Future<void> _editTransaction(TransactionModel tx) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionPage(existing: tx)));
    _loadTransactions();
  }

  Future<void> _deleteTransaction(TransactionModel tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Transaksi?"),
        content: const Text("Transaksi ini akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && tx.id != null) {
      await _db.deleteTransaction(tx.id!);
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KasKu")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text("KasKu Menu", style: TextStyle(fontSize: 24))),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Kategori"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text("Laporan"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Pengaturan"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: Column(
          children: [
            BalanceCard(income: totalIncome, expense: totalExpense),
            Expanded(
              child: TransactionList(
                transactions: _transactions,
                onEdit: _editTransaction,
                onDelete: _deleteTransaction,
              ),
            ),
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
