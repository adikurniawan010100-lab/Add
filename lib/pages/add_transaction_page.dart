import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/db_service.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionModel? existing;

  const AddTransactionPage({super.key, this.existing});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'expense';
  String _category = 'Lainnya';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Makan', 'Transport', 'Belanja', 'Hiburan', 'Tagihan', 'Gaji', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final tx = widget.existing!;
      _type = tx.type;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _descriptionController.text = tx.description;
      _category = tx.category;
      _selectedDate = tx.date;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final tx = TransactionModel(
      id: widget.existing?.id,
      type: _type,
      amount: double.tryParse(_amountController.text.replaceAll(RegExp(r'\D'), '')) ?? 0,
      category: _category,
      description: _descriptionController.text,
      date: _selectedDate,
    );

    final db = DbService();
    if (widget.existing == null) {
      await db.saveTransaction(tx);
    } else {
      await db.updateTransaction(tx);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existing == null ? 'Transaksi disimpan' : 'Transaksi diperbarui')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? "Tambah Transaksi" : "Edit Transaksi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                selection: {_type},
                onValueChanged: (val) => setState(() => _type = val.first),
                segments: const [
                  ButtonSegment(value: 'income', label: Text('Pemasukan')),
                  ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Jumlah",
                  hintText: formatter.format(0),
                  border: const OutlineInputBorder(),
                  prefix: const Text('Rp'),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Masukkan jumlah";
                  final num = double.tryParse(v.replaceAll(RegExp(r'\D'), ''));
                  if (num == null || num <= 0) return "Masukkan angka yang valid";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(labelText: "Kategori", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text("Tanggal"),
                subtitle: Text(DateFormat.yMMMd('id_ID').format(_selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: const Locale('id', 'ID'),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _submit, child: Text(widget.existing == null ? "Simpan" : "Perbarui")),
            ],
          ),
        ),
      ),
    );
  }
}
