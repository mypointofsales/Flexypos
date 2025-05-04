import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/database_helper.dart';
import '../services/api_service.dart';
import '../screens/subscreens/category_form_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _filteredCategories = [];
  Map<int?, int> _productCountPerCategory = {};
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isSyncing = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    debugPrint('Opening CategoryScreen');
    _loadCategoriesWithProductCount();
  }

  Future<void> _syncCategory() async {
    setState(() => _isSyncing = true);
    try {
      // 1️⃣ Push lokal unsynced ke server dulu
      final db = await DatabaseHelper.instance.database;
      final unsynced = await db.query('category', where: 'is_synced = 0');
      if (unsynced.isNotEmpty) {
        await _apiService.batchUpsertCategories(unsynced);
        for (final c in unsynced) {
          await db.update(
            'category',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [c['id']],
          );
        }
      }

      // 2️⃣ Setelah PUSH, baru PULL dari server dan replace lokal
      final apiCategories = await _apiService.getCategories();
      await db.delete('category');
      for (final c in apiCategories) {
        await db.insert('category', c);
      }
    } catch (e) {
      print('Sync error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync error: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isSyncing = false);
    await _loadCategoriesWithProductCount();
  }

  Future<void> _loadCategoriesWithProductCount() async {
    final db = await DatabaseHelper.instance.database;
    final categories = await db.query('category', orderBy: 'name ASC');
    final products = await db.query('product');

    final countMap = <int?, int>{};
    for (var p in products) {
      final catId = p['category_id'] as int?;
      countMap[catId] = (countMap[catId] ?? 0) + 1;
    }

    setState(() {
      _categories = categories;
      _productCountPerCategory = countMap;
      _applySearch();
    });
  }

  void _applySearch() {
    final all = [..._categories];
    all.add({'id': null, 'name': 'no_category_1'.tr(), 'color': '#DDDDDD'});

    setState(() {
      _filteredCategories =
          all.where((c) {
            final name = c['name'].toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();
    });
  }

  Future<void> _deleteCategory(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('category', where: 'id = ?', whereArgs: [id]);
    _loadCategoriesWithProductCount();
  }

  Future<bool> _confirmDelete(String name) async {
    return await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('confirm'.tr()),
            content: Text('delete_category_confirm'.tr(args: [name])),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('delete'.tr()),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 4,
        shadowColor: Colors.blueAccent.withOpacity(0.4),
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            _isSearching
                ? TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'search_category'.tr(),
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _applySearch();
                  },
                )
                : Text(
                  'category_title'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                  _applySearch();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon:
                _isSyncing
                    ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.sync),
            tooltip: 'Sync dengan server',
            onPressed: _isSyncing ? null : _syncCategory,
          ),
        ],
      ),
      body:
          _filteredCategories.isEmpty
              ? Center(child: Text('no_category'.tr()))
              : ListView.separated(
                itemCount: _filteredCategories.length,
                separatorBuilder:
                    (_, __) => const Divider(
                      indent: 16,
                      endIndent: 16,
                      height: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                itemBuilder: (_, i) {
                  final c = _filteredCategories[i];
                  final colorHex = c['color'] ?? '#DDDDDD';
                  final color = Color(
                    int.parse(colorHex.replaceFirst('#', '0xff')),
                  );
                  final catId = c['id'] as int?;
                  final count = _productCountPerCategory[catId] ?? 0;

                  final listTile = ListTile(
                    leading: CircleAvatar(backgroundColor: color, radius: 14),
                    title: Text(
                      c['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$count ${'items'.tr()}'),
                    onTap:
                        catId == null
                            ? null
                            : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CategoryFormScreen(category: c),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  _loadCategoriesWithProductCount();
                                }
                              });
                            },
                  );

                  if (catId == null) return listTile;

                  return Dismissible(
                    key: Key(catId.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) => _confirmDelete(c['name']),
                    onDismissed: (_) => _deleteCategory(catId),
                    child: listTile,
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0080FF),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryFormScreen()),
          ).then((value) {
            if (value == true) _loadCategoriesWithProductCount();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
