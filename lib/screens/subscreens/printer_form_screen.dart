import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';

class PrinterFormScreen extends StatefulWidget {
  final Map<String, dynamic>? printer;

  const PrinterFormScreen({super.key, this.printer});

  @override
  State<PrinterFormScreen> createState() => _PrinterFormScreenState();
}

class _PrinterFormScreenState extends State<PrinterFormScreen> {
  final _nameController = TextEditingController();
  String _selectedModel = 'No printer';
  bool _printReceipts = false;
  bool _printOrders = false;

  @override
  void initState() {
    super.initState();
    if (widget.printer != null) {
      _nameController.text = widget.printer!['name'] ?? '';
      _selectedModel = widget.printer!['model'] ?? 'No printer';
      _printReceipts = widget.printer!['print_receipt'] == 1;
      _printOrders = widget.printer!['print_order'] == 1;
    }
  }

  Future<void> _savePrinter() async {
    final db = await DatabaseHelper.instance.database;

    final data = {
      'name': _nameController.text.trim(),
      'model': _selectedModel,
      'print_receipt': _printReceipts ? 1 : 0,
      'print_order': _printOrders ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    if (widget.printer == null) {
      await db.insert('printers', data);
    } else {
      await db.update(
        'printers',
        data,
        where: 'id = ?',
        whereArgs: [widget.printer!['id']],
      );
    }

    Navigator.pop(context, true);
  }

  Future<void> _deletePrinter() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'printers',
      where: 'id = ?',
      whereArgs: [widget.printer!['id']],
    );
    Navigator.pop(context, true);
  }

  void _printTest() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('print_test_success'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 4,
        shadowColor: Colors.blueAccent.withOpacity(0.4),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.printer == null ? 'create_printer'.tr() : 'edit_printer'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _savePrinter,
            child: Text(
              'save'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'name'.tr()),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedModel,
                decoration: InputDecoration(labelText: 'printer_model'.tr()),
                items:
                    ['No printer', 'EPSON', 'BIXOLON']
                        .map(
                          (model) => DropdownMenuItem(
                            value: model,
                            child: Text(model),
                          ),
                        )
                        .toList(),
                onChanged:
                    (val) =>
                        setState(() => _selectedModel = val ?? 'No printer'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: Text('print_receipts'.tr()),
                value: _printReceipts,
                onChanged: (v) => setState(() => _printReceipts = v),
              ),
              SwitchListTile(
                title: Text('print_orders'.tr()),
                value: _printOrders,
                onChanged: (v) => setState(() => _printOrders = v),
              ),
              const Divider(height: 30),
              TextButton.icon(
                onPressed: _printTest,
                icon: const Icon(Icons.print),
                label: Text('print_test'.tr()),
              ),
              const SizedBox(height: 30),
              if (widget.printer != null)
                TextButton.icon(
                  onPressed: _deletePrinter,
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: Text(
                    'delete_printer'.tr(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
