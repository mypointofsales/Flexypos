import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryFormScreen extends StatefulWidget {
  final Map<String, dynamic>? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _nameController = TextEditingController();
  String? _selectedColor;

  final List<String> _colorOptions = [
    '#F5F5F5', // Light Gray
    '#FFCDD2', // Soft Red
    '#F8BBD0', // Soft Pink
    '#FFE0B2', // Soft Orange
    '#F0F4C3', // Soft Lime
    '#C8E6C9', // Soft Green
    '#BBDEFB', // Soft Blue
    '#E1BEE7', // Soft Purple
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!['name'] ?? '';
      _selectedColor = widget.category!['color'];
    }
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedColor == null) return;

    final db = await DatabaseHelper.instance.database;
    final data = {
      'name': name,
      'color': _selectedColor,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    if (widget.category == null) {
      await db.insert('category', data);
    } else {
      await db.update(
        'category',
        data,
        where: 'id = ?',
        whereArgs: [widget.category!['id']],
      );
    }

    Navigator.pop(context, true);
  }

  Future<void> _deleteCategory() async {
    final db = await DatabaseHelper.instance.database;
    if (widget.category != null) {
      await db.delete(
        'category',
        where: 'id = ?',
        whereArgs: [widget.category!['id']],
      );
    }
    Navigator.pop(context, true);
  }

  Widget _buildColorBox(String colorHex) {
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
    final isSelected = _selectedColor == colorHex;

    return GestureDetector(
      onTap: () => setState(() => _selectedColor = colorHex),
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border:
              isSelected
                  ? Border.all(width: 3, color: Colors.white)
                  : Border.all(color: Colors.grey.shade300),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
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
        title: Text(
          widget.category == null ? 'add_category'.tr() : 'edit_category'.tr(),

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _saveCategory,
            child: Text(
              'save'.tr(),
              style: TextStyle(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'category_name'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'c_hintext'.tr()),
            ),
            const SizedBox(height: 20),
            Text(
              'category_color'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(children: _colorOptions.map(_buildColorBox).toList()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
                side: const BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                'assign_items'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                'create_item'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.category != null)
              Center(
                child: TextButton.icon(
                  onPressed: _deleteCategory,
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: Text(
                    'delete_category'.tr(),
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
