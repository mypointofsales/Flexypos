import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_helper.dart';
import 'subscreens/modifier_form_screen.dart';

class ModifierScreen extends StatefulWidget {
  const ModifierScreen({super.key});

  @override
  State<ModifierScreen> createState() => _ModifierScreenState();
}

class _ModifierScreenState extends State<ModifierScreen> {
  List<Map<String, dynamic>> _modifiers = [];
  List<Map<String, dynamic>> _filteredModifiers = [];
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadModifiers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadModifiers() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query('modifiers', orderBy: 'name ASC');

    setState(() {
      _modifiers = result;
      _filterModifiers();
    });
  }

  void _filterModifiers() {
    setState(() {
      _filteredModifiers =
          _modifiers.where((m) {
            final name = m['name']?.toString().toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();
    });
  }

  Future<void> _deleteModifier(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('modifiers', where: 'id = ?', whereArgs: [id]);
    _loadModifiers();
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
                    hintText: 'search_modifier'.tr(),
                    hintStyle: const TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterModifiers();
                  },
                )
                : Text(
                  'modifiers'.tr(),
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
                  _searchController.clear();
                  _searchQuery = '';
                  _filterModifiers();
                }
              });
            },
          ),
        ],
      ),
      body:
          _filteredModifiers.isEmpty
              ? Center(child: Text('no_modifiers'.tr()))
              : ListView.separated(
                itemCount: _filteredModifiers.length,
                separatorBuilder:
                    (_, __) => const Divider(
                      indent: 16,
                      endIndent: 16,
                      thickness: 0.5,
                      height: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                itemBuilder: (_, i) {
                  final m = _filteredModifiers[i];
                  final options = (m['options'] ?? '')
                      .toString()
                      .split(',')
                      .where((o) => o.trim().isNotEmpty)
                      .join(', ');

                  return Dismissible(
                    key: Key(m['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.redAccent,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text('confirm'.tr()),
                              content: Text(
                                'delete_modifier_confirm'.tr(args: [m['name']]),
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
                    onDismissed: (_) => _deleteModifier(m['id']),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFD3D3D3),
                        child: Icon(
                          Icons.file_copy_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      title: Text(m['name']),
                      subtitle: Text(options),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ModifierFormScreen(modifier: m),
                          ),
                        ).then((value) {
                          if (value == true) _loadModifiers();
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
            MaterialPageRoute(builder: (_) => const ModifierFormScreen()),
          ).then((value) {
            if (value == true) _loadModifiers();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
