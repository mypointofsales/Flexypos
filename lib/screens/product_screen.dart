import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_helper.dart';
import '../services/api_service.dart';
import '../screens/subscreens/product_form_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _syncProduct() async {
    setState(() => _isSyncing = true);
    try {
      // 1️⃣ Push lokal unsynced ke server dulu
      final db = await DatabaseHelper.instance.database;
      final unsynced = await db.query('product', where: 'is_synced = 0');
      if (unsynced.isNotEmpty) {
        await _apiService.batchUpsertProducts(unsynced);
        for (final p in unsynced) {
          await db.update(
            'product',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [p['id']],
          );
        }
      }

      // 2️⃣ Setelah PUSH, baru PULL dari server dan replace lokal
      final apiProducts = await _apiService.getProducts();
      await db.delete('product');
      for (final p in apiProducts) {
        await db.insert('product', p);
      }
    } catch (e) {
      print('Sync error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync error: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isSyncing = false);
    await _loadData(); // Pastikan method ini memuat product dan kategori terbaru!
  }

  /// --- Load data dari SQLite lokal
  Future<void> _loadData() async {
    final db = await DatabaseHelper.instance.database;
    final categories = await db.query('category', orderBy: 'name ASC');
    final products = await db.query('product', orderBy: 'name ASC');
    setState(() {
      _categories = categories;
      _products = products;
      _filterProducts();
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts =
          _products.where((p) {
            final matchesSearch = p['name'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            final matchesCategory =
                _selectedCategoryId == null ||
                p['category_id'] == _selectedCategoryId;
            return matchesSearch && matchesCategory;
          }).toList();
    });
  }

  Future<void> _deleteProduct(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('product', where: 'id = ?', whereArgs: [id]);
    _loadData();
  }

  Widget _buildColorBox(String? colorHex) {
    if (colorHex == null) return const SizedBox(width: 30, height: 30);
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: color, shape: BoxShape.rectangle),
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
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'search_product'.tr(),
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterProducts();
                  },
                )
                : Row(
                  children: [
                    DropdownButton<int?>(
                      dropdownColor: Colors.white,
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      value: _selectedCategoryId,
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                          _filterProducts();
                        });
                      },
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'all_items'.tr(),
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ..._categories.map((c) {
                          return DropdownMenuItem<int?>(
                            value: c['id'] as int,
                            child: Text(
                              c['name'],
                              style: const TextStyle(color: Colors.blue),
                            ),
                          );
                        }),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _filterProducts();
                }
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
            onPressed: _isSyncing ? null : _syncProduct,
          ),
        ],
      ),

      body:
          _filteredProducts.isEmpty
              ? Center(child: Text('no_products'.tr()))
              : ListView.separated(
                itemCount: _filteredProducts.length,
                separatorBuilder:
                    (_, __) => const Divider(
                      indent: 16,
                      endIndent: 16,
                      thickness: 0.5,
                      height: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                itemBuilder: (_, i) {
                  final p = _filteredProducts[i];
                  final category = _categories.firstWhere(
                    (c) => c['id'] == p['category_id'],
                    orElse: () => {'color': '#DDDDDD'},
                  );

                  return Dismissible(
                    key: Key(p['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.redAccent,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text('confirm'.tr()),
                              content: Text(
                                'delete_product_confirm'.tr(args: [p['name']]),
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text('cancel'.tr()),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('delete'.tr()),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (direction) => _deleteProduct(p['id']),
                    child: ListTile(
                      leading: _buildColorBox(category['color']),
                      title: Text(p['name']),
                      subtitle: Text('Stok: ${p['stock'] ?? 0}'),
                      trailing: Text(
                        'Rp ${p['price']?.toStringAsFixed(0) ?? 0}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductFormScreen(product: p),
                          ),
                        ).then((value) {
                          if (value == true) {
                            _loadData();
                          }
                        });
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0080FF),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          ).then((value) {
            if (value == true) {
              _loadData();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
