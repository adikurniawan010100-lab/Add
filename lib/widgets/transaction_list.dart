import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final void Function(TransactionModel)? onEdit;
  final void Function(TransactionModel)? onDelete;

  const TransactionList({super.key, required this.transactions, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text("Belum ada transaksi"));
    }

    final grouped = <String, List<TransactionModel>>{};
    for (var tx in transactions.reversed) {
      final key = DateFormat.yMMMd('id_ID').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(entry.key, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey)),
            ),
            ...entry.value.map((tx) => Dismissible(
              key: Key(tx.id?.toString() ?? UniqueKey().toString()),
              direction: DismissDirection.endToStart,
              background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete, color: Colors.white)),
              confirmDismiss: (_) async {
                onDelete?.call(tx);
                return false;
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tx.type == 'income' ? Colors.green[100] : Colors.red[100],
                  child: Icon(
                    tx.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                    color: tx.type == 'income' ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(tx.description),
                subtitle: Text("${tx.category} • ${DateFormat.Hm('id_ID').format(tx.date)}"),
                trailing: SizedBox(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.simpleCurrency(locale: 'id_ID', decimalDigits: 0).format(tx.amount),
                        style: TextStyle(
                          color: tx.type == 'income' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => onEdit?.call(tx)),
                      IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => onDelete?.call(tx)),
                    ],
                  ),
                ),
              ),
            ))
          ],
        );
      }).toList(),
    );
  }
}
