import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/db_service.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryModel> _cats = [];
  final DbService _db = DbService();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await _db.getAllCategories();
    setState(() => _cats = cats.isEmpty ? defaultCategories() : cats);
  }

  List<CategoryModel> defaultCategories() {
    final defaults = [
      {"id": 0, "name": "Makan", "icon": "restaurant", "colorValue": 0xFFE57373},
      {"id": 1, "name": "Transport", "icon": "directions_car", "colorValue": 0xFF81C784},
      {"id": 2, "name": "Belanja", "icon": "shopping_cart", "colorValue": 0xFF64B5F6},
      {"id": 3, "name": "Hiburan", "icon": "movie", "colorValue": 0xFFBA68C8},
    ];
    return defaults.map((e) => CategoryModel.fromJson(e)).toList();
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Tambah Kategori"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nama", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _iconController, decoration: const InputDecoration(labelText: "Icon (nama icon Flutter)", border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal")),
          FilledButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                final cat = CategoryModel(name: _nameController.text, icon: _iconController.text.isEmpty ? 'category' : _iconController.text, colorValue: Colors.primaries[DateTime.now().millisecond % Colors.primaries.length].value);
                await _db.saveCategory(cat);
                _nameController.clear();
                _iconController.clear();
                Navigator.pop(c);
                _load();
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kategori")),
      body: _cats.isEmpty
          ? const Center(child: Text("Belum ada kategori"))
          : ListView.builder(
              itemCount: _cats.length,
              itemBuilder: (_, index) {
                final cat = _cats[index];
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Color(cat.colorValue), child: const Icon(Icons.category)),
                  title: Text(cat.name),
                  trailing: cat.id != null
                      ? IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () async {
                          await _db.deleteCategory(cat.id!);
                          _load();
                        })
                      : null,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), onPressed: _addCategory),
    );
  }
}
