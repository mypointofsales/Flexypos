import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_helper.dart';
import 'subscreens/printer_form_screen.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  List<Map<String, dynamic>> _printers = [];
  List<Map<String, dynamic>> _filteredPrinters = [];
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrinters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrinters() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('printers', orderBy: 'name ASC');

    setState(() {
      _printers = result;
      _filterPrinters();
    });
  }

  void _filterPrinters() {
    setState(() {
      _filteredPrinters =
          _printers.where((p) {
            final name = p['name']?.toString().toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();
    });
  }

  Future<void> _deletePrinter(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('printers', where: 'id = ?', whereArgs: [id]);
    _loadPrinters();
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
                    hintText: 'search_printer'.tr(),
                    hintStyle: const TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterPrinters();
                  },
                )
                : Text(
                  'printers'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                  _filterPrinters();
                }
              });
            },
          ),
        ],
      ),
      body:
          _filteredPrinters.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.print, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'no_printer'.tr(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'printer_instruction'.tr(),
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.separated(
                itemCount: _filteredPrinters.length,
                separatorBuilder:
                    (_, __) => const Divider(
                      indent: 16,
                      endIndent: 16,
                      thickness: 0.5,
                      height: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                itemBuilder: (_, i) {
                  final p = _filteredPrinters[i];
                  return Dismissible(
                    key: Key(p['id'].toString()),
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
                                'delete_printer_confirm'.tr(args: [p['name']]),
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
                    onDismissed: (_) => _deletePrinter(p['id']),
                    child: ListTile(
                      leading: const Icon(
                        Icons.print,
                        color: Color(0xFF0A192F),
                      ),
                      title: Text(p['name']),
                      subtitle: Text(p['model'] ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrinterFormScreen(printer: p),
                          ),
                        ).then((value) {
                          if (value == true) _loadPrinters();
                        });
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrinterFormScreen()),
          ).then((value) {
            if (value == true) _loadPrinters();
          });
        },
      ),
    );
  }
}
