import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class DbService {
  static const String _txKey = "transactions";
  static const String _catKey = "categories";

  // ---- Transactions ----
  Future<List<TransactionModel>> getAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_txKey) ?? [];
    return data.map((e) => TransactionModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveTransaction(TransactionModel tx) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAllTransactions();
    final nextId = list.isEmpty ? 0 : (list.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    final newTx = TransactionModel(
      id: nextId,
      type: tx.type,
      amount: tx.amount,
      category: tx.category,
      description: tx.description,
      date: tx.date,
      note: tx.note,
    );
    list.add(newTx);
    await prefs.setStringList(_txKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAllTransactions();
    final index = list.indexWhere((element) => element.id == tx.id);
    if (index != -1) {
      list[index] = tx;
    }
    await prefs.setStringList(_txKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> deleteTransaction(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAllTransactions();
    list.removeWhere((element) => element.id == id);
    await prefs.setStringList(_txKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }

  // ---- Categories ----
  Future<List<CategoryModel>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_catKey) ?? [];
    return data.map((e) => CategoryModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveCategory(CategoryModel cat) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAllCategories();
    final nextId = list.isEmpty ? 0 : (list.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    final newCat = CategoryModel(
      id: nextId,
      name: cat.name,
      icon: cat.icon,
      colorValue: cat.colorValue,
    );
    list.add(newCat);
    await prefs.setStringList(_catKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> deleteCategory(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAllCategories();
    list.removeWhere((element) => element.id == id);
    await prefs.setStringList(_catKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }
}
