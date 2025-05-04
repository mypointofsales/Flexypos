import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_helper.dart';
import 'subscreens/tax_form_screen.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  List<Map<String, dynamic>> _taxes = [];

  @override
  void initState() {
    super.initState();
    _loadTaxes();
  }

  Future<void> _loadTaxes() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('taxes', orderBy: 'name ASC');
    setState(() => _taxes = result);
  }

  Future<void> _deleteTax(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('taxes', where: 'id = ?', whereArgs: [id]);
    _loadTaxes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
        title: Text('taxes'.tr(), style: const TextStyle(color: Colors.white)),
      ),
      body:
          _taxes.isEmpty
              ? Center(child: Text('no_tax'.tr()))
              : ListView.separated(
                itemCount: _taxes.length,
                separatorBuilder:
                    (_, __) => const Divider(indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final t = _taxes[i];
                  return Dismissible(
                    key: Key(t['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text('confirm'.tr()),
                              content: Text(
                                'delete_tax_confirm'.tr(args: [t['name']]),
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
                    onDismissed: (_) => _deleteTax(t['id']),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFD3D3D3),
                        child: Icon(Icons.percent, color: Colors.grey),
                      ),
                      title: Text(t['name']),
                      subtitle: Text('${t['item_count']} items'),
                      trailing: Text('${t['rate']}%'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaxFormScreen(tax: t),
                          ),
                        ).then((value) {
                          if (value == true) _loadTaxes();
                        });
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaxFormScreen()),
          ).then((value) {
            if (value == true) _loadTaxes();
          });
        },
      ),
    );
  }
}
