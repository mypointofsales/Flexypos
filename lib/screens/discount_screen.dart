import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_helper.dart';
import 'subscreens/discount_form_screen.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  List<Map<String, dynamic>> _discounts = [];
  List<Map<String, dynamic>> _filtered = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDiscounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscounts() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('discounts', orderBy: 'name ASC');
    setState(() {
      _discounts = result;
      _applyFilter();
    });
  }

  void _applyFilter() {
    setState(() {
      _filtered =
          _discounts.where((d) {
            final name = d['name']?.toString().toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();
    });
  }

  Future<void> _deleteDiscount(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('discounts', where: 'id = ?', whereArgs: [id]);
    _loadDiscounts();
  }

  String _displayValue(Map<String, dynamic> d) {
    final isPercent = d['is_percent'] == 1;
    final value = d['value'] ?? 0;
    return isPercent
        ? '${value.toStringAsFixed(0)}%'
        : 'Rp${value.toStringAsFixed(0)}';
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
                    hintText: 'search_discount'.tr(),
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _applyFilter();
                  },
                )
                : Text(
                  'discounts'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                  _applyFilter();
                }
              });
            },
          ),
        ],
      ),
      body:
          _filtered.isEmpty
              ? Center(child: Text('no_discounts'.tr()))
              : ListView.separated(
                itemCount: _filtered.length,
                separatorBuilder:
                    (_, __) => const Divider(
                      indent: 16,
                      endIndent: 16,
                      height: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                itemBuilder: (_, i) {
                  final d = _filtered[i];
                  return Dismissible(
                    key: Key(d['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss:
                        (_) => showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text('confirm'.tr()),
                                content: Text(
                                  'delete_discount_confirm'.tr(
                                    args: [d['name']],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text('cancel'.tr()),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text('delete'.tr()),
                                  ),
                                ],
                              ),
                        ),
                    onDismissed: (_) => _deleteDiscount(d['id']),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFD3D3D3),
                        child: Icon(Icons.local_offer, color: Colors.grey),
                      ),
                      title: Text(d['name']),
                      trailing: Text(_displayValue(d)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiscountFormScreen(discount: d),
                          ),
                        ).then((value) {
                          if (value == true) _loadDiscounts();
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
            MaterialPageRoute(builder: (_) => const DiscountFormScreen()),
          ).then((value) {
            if (value == true) _loadDiscounts();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
