import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';

class ModifierFormScreen extends StatefulWidget {
  final Map<String, dynamic>? modifier;

  const ModifierFormScreen({super.key, this.modifier});

  @override
  State<ModifierFormScreen> createState() => _ModifierFormScreenState();
}

class _ModifierFormScreenState extends State<ModifierFormScreen> {
  final _nameController = TextEditingController();
  List<Map<String, dynamic>> _options = [];

  @override
  void initState() {
    super.initState();
    if (widget.modifier != null) {
      _nameController.text = widget.modifier!['name'] ?? '';
      final rawOptions =
          widget.modifier!['options']?.toString().split(',') ?? [];
      _options =
          rawOptions.where((o) => o.trim().isNotEmpty).map((o) {
            final parts = o.split(':');
            return {
              'name': parts.first.trim(),
              'price': parts.length > 1 ? parts[1].trim() : '0',
            };
          }).toList();
    } else {
      _options = [
        {'name': '', 'price': '0'},
      ];
    }
  }

  void _addOption() {
    setState(() => _options.add({'name': '', 'price': '0'}));
  }

  void _removeOption(int index) {
    setState(() => _options.removeAt(index));
  }

  Future<void> _saveModifier() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final options = _options
        .where((o) => o['name'].toString().trim().isNotEmpty)
        .map((o) => '${o['name']}:${o['price']}')
        .join(',');

    final db = await DatabaseHelper.instance.database;
    final data = {
      'name': name,
      'options': options,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    if (widget.modifier == null) {
      await db.insert('modifiers', data);
    } else {
      await db.update(
        'modifiers',
        data,
        where: 'id = ?',
        whereArgs: [widget.modifier!['id']],
      );
    }

    Navigator.pop(context, true);
  }

  Future<void> _deleteModifier() async {
    if (widget.modifier == null) return;
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'modifiers',
      where: 'id = ?',
      whereArgs: [widget.modifier!['id']],
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
          widget.modifier == null ? 'add_modifier'.tr() : 'edit_modifier'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveModifier,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'modifier_name'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            //const SizedBox(height: 1),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                //border: OutlineInputBorder(),
                //contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'modifier_options'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ..._options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.drag_indicator, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'option_name'.tr(),
                            ),
                            onChanged: (v) => option['name'] = v,
                            controller: TextEditingController.fromValue(
                              TextEditingValue(text: option['name']),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _removeOption(index),
                        ),
                      ],
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'price'.tr()),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => option['price'] = v,
                      controller: TextEditingController.fromValue(
                        TextEditingValue(text: option['price']),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              label: Text(
                'add_option'.tr(),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (widget.modifier != null)
              Center(
                child: TextButton.icon(
                  onPressed: _deleteModifier,
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: Text(
                    'delete_modifier'.tr(),
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
