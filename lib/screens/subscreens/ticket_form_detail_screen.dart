import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';

class TicketFormDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic> updatedItem)? onUpdate;
  final Function()? onDelete;

  const TicketFormDetailScreen({
    super.key,
    required this.item,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<TicketFormDetailScreen> createState() => _TicketFormDetailScreenState();
}

class _TicketFormDetailScreenState extends State<TicketFormDetailScreen> {
  late int _quantity;
  late bool _includeTax;
  int? _selectedTaxId;

  List<Map<String, dynamic>> _discounts = [];
  List<Map<String, dynamic>> _taxes = [];
  final Map<int, bool> _selectedTaxes = {}; // ID pajak → aktif/tidak

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    debugPrint('📥 TicketFormDetailScreen init with item: ${widget.item}');
    _quantity = widget.item['quantity'] ?? 1;
    _includeTax = widget.item['include_tax'] ?? true;
    _selectedTaxId = widget.item['tax_id'] ?? widget.item['taxId'];
    _loadDiscountsAndTaxes();
  }

  Future<void> _loadDiscountsAndTaxes() async {
    final db = await DatabaseHelper.instance.database;
    final discountData = await db.query('discounts');
    final taxData = await db.query('taxes');

    setState(() {
      _discounts = discountData;
      _taxes = taxData;

      // Siapkan switch pajak
      for (var tax in _taxes) {
        final id = tax['id'] as int;
        _selectedTaxes[id] = _selectedTaxId == id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0A192F);
    final item = widget.item;
    final price = item['price'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(
          'quantity_price'.tr(
            args: [_quantity.toString(), _currencyFormat.format(price)],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final selectedTax =
                  _selectedTaxes.entries
                      .firstWhere(
                        (e) => e.value,
                        orElse: () => const MapEntry(0, false),
                      )
                      .key;
              widget.onUpdate?.call({
                ...item,
                'quantity': _quantity,
                'include_tax': _includeTax,
                'taxId': selectedTax > 0 ? selectedTax : null,
              });
              Navigator.pop(context);
            },
            child: Text(
              'save'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'quantity'.tr()}: $_quantity'),
            Slider(
              value: _quantity.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: _quantity.toString(),
              onChanged: (val) {
                setState(() {
                  _quantity = val.round();
                });
              },
            ),
            const SizedBox(height: 16),
            Text('discount'.tr(), style: const TextStyle(color: Colors.green)),
            ..._discounts.map((d) {
              final label =
                  '${d['name']} - ${d['value']} ${d['is_percent'] == 1 ? '%' : ''}';
              return SwitchListTile(
                value: false,
                onChanged: (_) {},
                title: Text(label),
              );
            }),
            const SizedBox(height: 12),
            Text('tax'.tr(), style: const TextStyle(color: Colors.green)),
            ..._taxes.map((t) {
              final taxId = t['id'] as int;
              final label = '${t['name']} - ${t['rate']}%';
              final isActive = _selectedTaxes[taxId] ?? false;

              return SwitchListTile(
                value: isActive,
                onChanged: (val) {
                  setState(() {
                    _selectedTaxes.updateAll((key, _) => false); // hanya satu
                    _selectedTaxes[taxId] = val;
                  });
                },
                title: Text(label),
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  widget.onDelete?.call();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
                child: Text(
                  'delete_from_ticket'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
