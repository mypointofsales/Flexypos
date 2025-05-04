import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';

class DiscountFormScreen extends StatefulWidget {
  final Map<String, dynamic>? discount;

  const DiscountFormScreen({super.key, this.discount});

  @override
  State<DiscountFormScreen> createState() => _DiscountFormScreenState();
}

class _DiscountFormScreenState extends State<DiscountFormScreen> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  bool _isPercent = true;

  @override
  void initState() {
    super.initState();
    if (widget.discount != null) {
      _nameController.text = widget.discount!['name'] ?? '';
      _valueController.text = widget.discount!['value']?.toString() ?? '';
      _isPercent = widget.discount!['is_percent'] == 1;
    }
  }

  Future<void> _saveDiscount() async {
    final db = await DatabaseHelper.instance.database;

    final data = {
      'name': _nameController.text.trim(),
      'value': double.tryParse(_valueController.text) ?? 0,
      'is_percent': _isPercent ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    if (widget.discount == null) {
      await db.insert('discounts', data);
    } else {
      await db.update(
        'discounts',
        data,
        where: 'id = ?',
        whereArgs: [widget.discount!['id']],
      );
    }

    Navigator.pop(context, true);
  }

  Future<void> _deleteDiscount() async {
    if (widget.discount == null) return;
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'discounts',
      where: 'id = ?',
      whereArgs: [widget.discount!['id']],
    );
    Navigator.pop(context, true);
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
          widget.discount == null ? 'add_discount'.tr() : 'edit_discount'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveDiscount,
            child: Text(
              'save'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'name'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'name_hint'.tr()),
            ),
            const SizedBox(height: 24),
            Text(
              'value'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: '0'),
                  ),
                ),
                const SizedBox(width: 12),
                ToggleButtons(
                  isSelected: [_isPercent, !_isPercent],
                  onPressed: (index) {
                    setState(() => _isPercent = index == 0);
                  },
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    minWidth: 40,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('%'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Σ'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'discount_hint'.tr(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 40),
            if (widget.discount != null)
              Center(
                child: TextButton.icon(
                  onPressed: _deleteDiscount,
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: Text(
                    'delete_discount'.tr(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
