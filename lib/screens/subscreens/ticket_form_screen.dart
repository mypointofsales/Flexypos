import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'save_form_screen.dart';
import 'open_ticket_screen.dart';
import '../../services/database_helper.dart';
import 'ticket_form_detail_screen.dart';

class TicketFormScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final int customerId; // Tambahkan ini
  const TicketFormScreen({
    super.key,
    required this.cart,
    required this.customerId,
  });

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  late List<Map<String, dynamic>> _localCart;
  bool _isFromOpenTicket = false; // 🔥 Tambahkan ini

  @override
  void initState() {
    super.initState();

    debugPrint('Opening TicketFormScreen | customerId: ${widget.customerId}');
    // _localCart = List<Map<String, dynamic>>.from(widget.cart);
    _localCart =
        widget.cart.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  double get subtotal => _localCart.fold(
    0,
    (sum, item) => sum + (item['price'] * item['quantity']),
  );
  double get tax => subtotal * 0.1;
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0A192F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Row(
          children: [
            Text(
              'ticket'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            if (_localCart.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_localCart.fold<int>(0, (sum, item) => sum + (item['quantity'] as int))}', // ✅ Total kuantitas semua barang
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            final orderId =
                _localCart.isNotEmpty ? _localCart.first['order_id'] : null;

            Navigator.pop(context, {
              'status': 'restored',
              'cart': _localCart,
              'order_id': orderId,
            });
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ..._localCart.map(
            (item) => Dismissible(
              key: Key(item['product_id'].toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                setState(() {
                  _localCart.remove(item);
                });
              },
              child: ListTile(
                title: Text('${item['quantity']} × ${item['name']}'),
                trailing: Text(
                  'Rp${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final itemIndex = _localCart.indexOf(item);
                  if (itemIndex == -1) return;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TicketFormDetailScreen(
                            item: Map<String, dynamic>.from(
                              _localCart[itemIndex],
                            ),
                            onUpdate: (updatedItem) {
                              setState(() {
                                _localCart[itemIndex] = updatedItem;
                              });
                            },
                            onDelete: () {
                              setState(() {
                                _localCart.removeAt(itemIndex);
                              });
                            },
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text('tax'.tr()),
            trailing: Text(
              'Rp${tax.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text(
              'total'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              'Rp${total.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    debugPrint(
                      '💾 [TicketForm] Tombol SAVE ditekan, cartLen: ${_localCart.length}',
                    );

                    if (_localCart.isEmpty) {
                      debugPrint('📂 Cart kosong, buka OpenTicketScreen...');
                      final openTickets = await DatabaseHelper.instance.database
                          .then(
                            (db) => db.rawQuery('''
                        SELECT so.id, so.ticket_name, so.total, so.created_at
                        FROM sales_order so
                        WHERE so.status = 'pending'
                        ORDER BY so.created_at DESC
                      '''),
                          );

                      final selectedOrderId = await Navigator.push<int>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => OpenTicketScreen(
                                tickets:
                                    openTickets.map((row) {
                                      final createdAt =
                                          DateTime.tryParse(
                                            row['created_at'].toString(),
                                          ) ??
                                          DateTime.now();
                                      final fallbackName =
                                          'Ticket - ${createdAt.hour}:${createdAt.minute}';
                                      final name =
                                          (row['ticket_name']
                                                      ?.toString()
                                                      .isNotEmpty ??
                                                  false)
                                              ? row['ticket_name'].toString()
                                              : fallbackName;
                                      return {
                                        'id': row['id'],
                                        'name': name,
                                        'subtitle':
                                            '${DateTime.now().difference(createdAt).inMinutes} min ago',
                                        'total': row['total'] ?? 0,
                                        'created_at':
                                            row['created_at'], // ⬅️ Tambahkan ini!
                                      };
                                    }).toList(),
                              ),
                        ),
                      );

                      if (selectedOrderId != null) {
                        debugPrint(
                          '✅ Tiket dipilih dari OpenTicketScreen, orderId: $selectedOrderId',
                        );
                        final lines = await DatabaseHelper.instance.database
                            .then(
                              (db) => db.rawQuery(
                                '''
                                  SELECT sol.*, p.name
                                  FROM sales_order_line sol
                                  JOIN product p ON p.id = sol.product_id
                                  WHERE sol.sales_order_id = ?
                                ''',
                                [selectedOrderId],
                              ),
                            );

                        setState(() {
                          _localCart.clear();
                          _isFromOpenTicket = true;
                          for (var line in lines) {
                            _localCart.add({
                              'product_id': line['product_id'],
                              'name':
                                  line['name'] ??
                                  '', // ✅ sekarang dapat nama produk
                              'price': line['price'],
                              'cost': line['cost'],
                              'quantity': line['quantity'],
                              'note': line['note'],
                              'order_id': selectedOrderId,

                              'taxId':
                                  line['tax_id'], // ✅ ganti dari 'tax_id' ke 'taxId'
                            });
                            debugPrint('📦 Cart content:');
                            for (var i = 0; i < _localCart.length; i++) {
                              debugPrint(
                                ' - ${_localCart[i]['quantity']}x ${_localCart[i]['name']} @ Rp${_localCart[i]['price']}',
                              );
                            }
                          }
                        });
                      }
                    } else {
                      final isExistingOrder =
                          _localCart.isNotEmpty &&
                          _localCart.first['order_id'] != null;

                      if (isExistingOrder) {
                        final db = await DatabaseHelper.instance.database;
                        final orderId = _localCart.first['order_id'];
                        debugPrint(
                          '♻️ Update order_id: $orderId, item count: ${_localCart.length}',
                        );

                        await db.delete(
                          'sales_order_line',
                          where: 'sales_order_id = ?',
                          whereArgs: [orderId],
                        );

                        for (var item in _localCart) {
                          final qty = item['quantity'] as int;
                          final price = item['price'] as double;

                          await db.insert('sales_order_line', {
                            'sales_order_id': orderId,
                            'product_id': item['product_id'],
                            'quantity': qty,
                            'price': price,
                            'cost': (item['cost'] as num?)?.toDouble() ?? 0,

                            // Diskon (jika ada, default 0)
                            'discount_id': item['discountId'] as int? ?? 0,
                            'discount_rate':
                                item['discountRate'] as double? ?? 0.0,
                            'discount_value':
                                item['discountValue'] as double? ?? 0.0,

                            // Pajak (ikut product)
                            'tax_id': item['taxId'] as int? ?? 0,
                            'tax_rate': item['taxRate'] as double? ?? 0.0,
                            'tax_value': item['taxValue'] as double? ?? 0.0,

                            // Subtotal & Catatan
                            'subtotal': price * qty,
                            'note': item['note'] as String? ?? '',

                            'created_at': DateTime.now().toIso8601String(),
                            'updated_at': DateTime.now().toIso8601String(),
                          });
                        }

                        double total = _localCart.fold(
                          0.0,
                          (sum, item) =>
                              sum + (item['price'] * item['quantity']),
                        );

                        await db.update(
                          'sales_order',
                          {
                            'total': total,
                            'updated_at': DateTime.now().toIso8601String(),
                            'status': 'pending',
                          },
                          where: 'id = ?',
                          whereArgs: [orderId],
                        );

                        if (context.mounted) {
                          debugPrint(
                            '✅ Ticket berhasil diupdate, kembali ke SaleFormScreen',
                          );
                          Navigator.pop(context, {
                            'order_id': orderId,
                            'status': 'updated',
                            'cart': _localCart,
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Ticket updated')),
                          );
                        }
                      } else {
                        debugPrint('🆕 Menyimpan sebagai ticket baru...');
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => SaveFormScreen(
                                  cart: _localCart,
                                  customerId:
                                      widget
                                          .customerId, // ✅ gunakan yang dikirim dari parent
                                ),
                          ),
                        );

                        if (result != null && result['order_id'] != null) {
                          debugPrint(
                            '✅ Ticket baru berhasil disimpan: ${result['order_id']}',
                          );
                          if (context.mounted) {
                            Navigator.pop(context, {
                              'order_id': result['order_id'],
                              'status': 'new',
                              'cart': _localCart,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Ticket saved')),
                            );
                          }
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _localCart.isNotEmpty
                            ? 'save'.tr()
                            : 'open_tickets'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Charge logic nanti
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    '${'charge'.tr()} Rp${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
