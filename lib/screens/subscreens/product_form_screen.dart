import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;

  bool _isTrackStock = false;
  bool _soldByEach = true;

  String? _selectedColor;
  String? _selectedShape;

  List<Map<String, dynamic>> _allModifiers = [];
  List<int> _selectedModifierIds = [];

  List<Map<String, dynamic>> _taxes = [];
  int? _selectedTaxId;

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

  final List<String> _shapeOptions = ['square', 'circle', 'star', 'hex'];

  @override
  void initState() {
    super.initState();
    debugPrint('Opening ProductFormScreen');
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _priceController.text = widget.product!['price']?.toString() ?? '';
      _costController.text = widget.product!['cost']?.toString() ?? '';
      _stockController.text = widget.product!['stock']?.toString() ?? '';
      _skuController.text = widget.product!['sku'] ?? '';
      _barcodeController.text = widget.product!['barcode'] ?? '';
      _selectedCategoryId = widget.product!['category_id'];
      _isTrackStock = widget.product!['track_stock'] == 1;
      _soldByEach = widget.product!['sold_by'] != 'weight';
      final dynamic raw = widget.product!['tax'];
      _selectedTaxId = raw is int ? raw : int.tryParse(raw.toString());
      _selectedColor = widget.product!['color'];
      _selectedShape = widget.product!['shape'];
    }
    _loadCategories();
    _loadModifiers();
    _loadTaxes();
  }

  Future<void> _loadTaxes() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('taxes', orderBy: 'name');
    setState(() => _taxes = result);

    // kalau sedang edit, tetapkan pilihan awal
    if (widget.product != null && widget.product!['tax_id'] != null) {
      _selectedTaxId = widget.product!['tax_id'] as int;
    }
  }

  Future<void> _loadModifiers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('modifiers');
    setState(() => _allModifiers = result);

    // load data jika sedang edit product
    if (widget.product != null && widget.product!['modifier_ids'] != null) {
      final ids = widget.product!['modifier_ids'].toString().split(',');
      _selectedModifierIds =
          ids.where((e) => e.trim().isNotEmpty).map(int.parse).toList();
    }
  }

  Future<void> _loadCategories() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('category', orderBy: 'name ASC');
    setState(() => _categories = result);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final db = await DatabaseHelper.instance.database;
    final data = {
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0,
      'cost': double.tryParse(_costController.text) ?? 0,
      'stock': int.tryParse(_stockController.text) ?? 0,
      'sku': _skuController.text.trim(),
      'barcode': _barcodeController.text.trim(),
      'category_id': _selectedCategoryId,
      'track_stock': _isTrackStock ? 1 : 0,
      'modifier_ids': _selectedModifierIds.join(','),
      'sold_by': _soldByEach ? 'each' : 'weight',

      'color': _selectedColor,
      'shape': _selectedShape,
      'tax_id': _selectedTaxId ?? 0,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    if (widget.product == null) {
      await db.insert('product', data);
    } else {
      await db.update(
        'product',
        data,
        where: 'id = ?',
        whereArgs: [widget.product!['id']],
      );
    }

    Navigator.pop(context, true);
  }

  Future<void> _deleteProduct() async {
    if (widget.product == null) return;
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'product',
      where: 'id = ?',
      whereArgs: [widget.product!['id']],
    );
    Navigator.pop(context, true);
  }

  Widget _buildColorBox(String hex) {
    final color = Color(int.parse(hex.replaceFirst('#', '0xff')));
    final isSelected = _selectedColor == hex;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = hex),
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(width: 3, color: Colors.white) : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  Widget _buildShapeBox(String shape) {
    final isSelected = _selectedShape == shape;
    IconData icon;
    switch (shape) {
      case 'circle':
        icon = Icons.circle;
        break;
      case 'star':
        icon = Icons.star;
        break;
      case 'hex':
        icon = Icons.hexagon;
        break;
      default:
        icon = Icons.crop_square;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedShape = shape),
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          shape: BoxShape.rectangle,
        ),
        child:
            isSelected
                ? Icon(icon, color: Colors.green)
                : Icon(icon, color: Colors.grey),
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // ← ini bagian penting
        title: Text(
          widget.product == null ? 'add_product'.tr() : 'edit_item'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProduct,
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'name'.tr(),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ), // ← yang benar
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),

              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'category'.tr(),
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                items:
                    _categories.map<DropdownMenuItem<int>>((c) {
                      return DropdownMenuItem<int>(
                        value: c['id'] as int,
                        child: Text(c['name']),
                      );
                    }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategoryId = val;
                  });
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'sold_by'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0A192F),
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: _soldByEach,
                    onChanged: (v) => setState(() => _soldByEach = true),
                  ),

                  const Text('each').tr(),
                  Radio(
                    value: false,
                    groupValue: _soldByEach,
                    onChanged: (v) => setState(() => _soldByEach = false),
                  ),
                  const Text('weight').tr(),
                ],
              ),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'price'.tr(),
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'cost'.tr(),
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  labelText: 'sku'.tr(),
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'barcode'.tr(),
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),

              SwitchListTile(
                title: Text('track_stock'.tr()),
                activeColor: Colors.green,
                value: _isTrackStock,
                onChanged: (v) => setState(() => _isTrackStock = v),
              ),

              const Divider(height: 32),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'modifiers'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      //fontSize: 16,
                      //color: Colors.green,
                    ),
                  ),
                ),
              ),

              Column(
                children:
                    _allModifiers.map((mod) {
                      final modId = mod['id'] as int;
                      final isSelected = _selectedModifierIds.contains(modId);
                      final options = (mod['options'] ?? '')
                          .toString()
                          .split(',')
                          .where((o) => o.trim().isNotEmpty)
                          .join(', ');

                      return SwitchListTile(
                        title: Text(mod['name']),
                        subtitle: Text(options),
                        activeColor: Colors.green,
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val) {
                              _selectedModifierIds.add(modId);
                            } else {
                              _selectedModifierIds.remove(modId);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
              const Divider(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'taxes'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0A192F),
                    ),
                  ),
                ),
              ),

              // Ganti RadioListTile ke SwitchListTile:
              ..._taxes.map((tax) {
                final id = tax['id'] as int;
                final name = tax['name'] as String;
                final rate = tax['rate'] as num;
                final isOn = _selectedTaxId == id;

                return SwitchListTile(
                  title: Text('$name (${rate.toString()}%)'),
                  value: isOn,
                  activeColor: Colors.green,
                  onChanged: (v) {
                    setState(() {
                      if (v) {
                        _selectedTaxId = id; // pilih ini
                      } else {
                        _selectedTaxId = null; // batal pilih
                      }
                    });
                  },
                );
              }),

              const Divider(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'representation_on_pos'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0A192F),
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  Radio(value: 'color', groupValue: 'color', onChanged: (_) {}),
                  const Text('color_and_shape').tr(),
                  Radio(value: 'image', groupValue: 'color', onChanged: null),
                  const Text('image').tr(),
                ],
              ),
              Wrap(children: _colorOptions.map(_buildColorBox).toList()),
              const SizedBox(height: 10),
              Wrap(children: _shapeOptions.map(_buildShapeBox).toList()),

              const SizedBox(height: 30),
              if (widget.product != null)
                TextButton.icon(
                  onPressed: _deleteProduct,
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  label: Text(
                    'delete_item'.tr(),
                    style: TextStyle(
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
