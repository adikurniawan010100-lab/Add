import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';
import '../services/db_service.dart';
import '../services/export_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DbService _db = DbService();

  Future<void> _exportCsv() async {
    final txs = await _db.getAllTransactions();
    await ExportService.exportToCsv(txs, onResult: (msg) {
      if (mounted && msg != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    });
  }

  Future<void> _exportJsonBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final txData = prefs.getStringList('transactions') ?? [];
    final catData = prefs.getStringList('categories') ?? [];
    final jsonContent = jsonEncode({"transactions": txData, "categories": catData});

    try {
      final dir = await _db.getAllTransactions().then((_) => null);
      final file = File('/storage/emulated/0/Download/kasku_backup.json');
      await file.create(recursive: true);
      await file.writeAsString(jsonContent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Backup JSON tersimpan di ${file.path}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal export JSON: $e")));
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Semua Data?"),
        content: const Text("Semua transaksi dan kategori akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('transactions');
      await prefs.remove('categories');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua data berhasil dihapus")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        children: [
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text("Ekspor ke CSV"),
            onTap: _exportCsv,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Ekspor Backup JSON"),
            onTap: _exportJsonBackup,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: const Text("Hapus Semua Data", style: TextStyle(color: Colors.red)),
            onTap: _clearAllData,
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text("KasKu v1.0.1"),
            subtitle: Text("Aplikasi Manajemen Keuangan Pribadi"),
          ),
        ],
      ),
    );
  }
}
