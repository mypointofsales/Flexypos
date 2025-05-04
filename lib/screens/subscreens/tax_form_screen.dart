import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';

class TaxFormScreen extends StatefulWidget {
  final Map<String, dynamic>? tax;

  const TaxFormScreen({super.key, this.tax});

  @override
  State<TaxFormScreen> createState() => _TaxFormScreenState();
}

class _TaxFormScreenState extends State<TaxFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  String _selectedType = 'added';

  @override
  void initState() {
    super.initState();
    debugPrint('Opening TaxFormScreen');
    if (widget.tax != null) {
      _nameController.text = widget.tax!['name'] ?? '';
      _rateController.text = widget.tax!['rate'].toString();
      _selectedType = widget.tax!['type'];
    }
  }

  Future<void> _saveTax() async {
    if (!_formKey.currentState!.validate()) return;

    final db = await DatabaseHelper.instance.database;
    final data = {
      'name': _nameController.text.trim(),
      'rate': double.tryParse(_rateController.text) ?? 0,
      'type': _selectedType,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    if (widget.tax == null) {
      await db.insert('taxes', data);
    } else {
      await db.update(
        'taxes',
        data,
        where: 'id = ?',
        whereArgs: [widget.tax!['id']],
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('taxes', where: 'id = ?', whereArgs: [widget.tax!['id']]);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryDark = const Color(
      0xFF0A192F,
    ); // menyesuaikan warna pada kode Anda

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.tax == null ? 'create_tax'.tr() : 'edit_tax'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveTax,
            child: Text(
              'save'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'name'.tr(),
                border: const UnderlineInputBorder(),
              ),
              validator:
                  (val) =>
                      (val == null || val.trim().isEmpty)
                          ? 'field_required'.tr()
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'tax_rate'.tr(),
                suffixText: '%',
                border: const UnderlineInputBorder(),
              ),
              validator: (val) {
                final rate = double.tryParse(val ?? '');
                if (rate == null || rate < 0) return 'invalid_number'.tr();
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'type'.tr(),
                border: const UnderlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'added',
                  child: Text('added_to_price'.tr()),
                ),
                DropdownMenuItem(
                  value: 'included',
                  child: Text('included_in_price'.tr()),
                ),
              ],
              onChanged:
                  (val) => setState(() => _selectedType = val ?? 'added'),
            ),
            const SizedBox(height: 24),
            // Tombol "Terapkan pada barang-barang"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryDark,
                side: BorderSide(color: primaryDark, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                // TODO: implementasikan logika menerapkan pajak ke barang-barang
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('apply_to_items_not_implemented'.tr()),
                  ),
                );
              },
              child: Text(
                'apply_to_items'.tr().toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.tax != null) ...[
              const SizedBox(height: 32),
              Divider(color: Colors.grey.shade400),
              Center(
                child: TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: Text(
                    'delete_tax'.tr(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
