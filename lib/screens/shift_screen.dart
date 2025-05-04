import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_helper.dart';
import '../widgets/custom_drawer.dart';
import '../screens/welcome_screen.dart';
import '../screens/sales_screen.dart';
import '../screens/receipt_screen.dart';
import '../screens/subscreens/sales_form_screen.dart';

import '../widgets/settings_screen.dart';
import '../widgets/item_screens.dart';

import '../screens/subscreens/shift_form_screen.dart';

class ShiftScreen extends StatefulWidget {
  final String afterOpenShift; // 'sales' atau 'shift'
  const ShiftScreen({super.key, this.afterOpenShift = 'shift'});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  bool _isDrawerOpen = false;
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkIfShiftIsOpen(); // <- Tambahkan ini
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      _isDrawerOpen ? _drawerController.forward() : _drawerController.reverse();
    });
  }

  Future<int> createInitialSalesOrder({
    required int shiftId,
    required int customerId,
    required List<Map<String, dynamic>> products, // berisi id, price, cost, qty
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();

    // 1. Buat sales_order entry
    final orderNumber = 'SO-${now.microsecondsSinceEpoch}';
    final orderId = await db.insert('sales_order', {
      'order_number': orderNumber,
      'created_at': now.toIso8601String(),
      'status': 'draft',
      'shift_id': shiftId,
      'customer_id': customerId,
    });

    double total = 0;

    // 2. Masukkan semua item ke sales_order_line
    for (var item in products) {
      final subtotal = item['price'] * item['quantity'];
      total += subtotal;

      await db.insert('sales_order_line', {
        'sales_order_id': orderId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
        'cost': item['cost'] ?? 0,
        'subtotal': subtotal,
        'note': item['note'] ?? '',
      });
    }

    // 3. Update total order
    await db.update(
      'sales_order',
      {'total': total},
      where: 'id = ?',
      whereArgs: [orderId],
    );

    return orderId;
  }

  Future<void> _checkIfShiftIsOpen() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'shift',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.afterOpenShift == 'shift') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ShiftFormScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SaleFormScreen()),
          );
        }
      });
    }
  }

  void _navigateTo(String route) {
    _toggleDrawer();
    Future.delayed(const Duration(milliseconds: 300), () {
      switch (route) {
        case 'sales':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesScreen()),
          );
          break;
        case 'receipts':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReceiptScreen()),
          );
          break;
        case 'shift':
          break;
        case 'items':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ItemScreen()),
          );
          break;
        case 'settings':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
          break;
        case 'logout':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
          break;
      }
    });
  }

  Future<void> _openShift() async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'shift',
      {'is_active': 0},
      where: 'is_active = ?',
      whereArgs: [1],
    );

    final now = DateTime.now();

    await db.insert('shift', {
      'shift_name': 'Shift ${now.hour}:${now.minute}',
      'start_time': now.toIso8601String(),
      'opening_cash':
          int.tryParse(
            _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0,
      'is_active': 1,
      'closing_cash': null,
      'end_time': null,
    });
    // Ambil shiftId terbaru
    final shiftIdResult = await db.rawQuery(
      'SELECT id FROM shift WHERE is_active = 1 ORDER BY id DESC LIMIT 1',
    );
    final shiftId = shiftIdResult.first['id'] as int;

    // Contoh produk default (bisa kosong dulu atau ambil dari cart)
    final dummyProducts =
        <Map<String, dynamic>>[]; // kosongin dulu kalau belum ada

    // Panggil createInitialSalesOrder
    await createInitialSalesOrder(
      shiftId: shiftId,
      customerId: 0,
      products: dummyProducts,
    );
    // Navigasi berdasarkan asal
    if (widget.afterOpenShift == 'shift') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ShiftFormScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SaleFormScreen()),
      );
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ✅ AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A192F),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'shift_data'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: _toggleDrawer,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Form Open Shift
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'specify_cash_amount'.tr(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'amount'.tr(),
                      prefixText: 'Rp',
                      //border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _openShift,
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
                      'open_shift'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          AnimatedBuilder(
            animation: _drawerController,
            builder: (context, child) {
              double slide = 280.0 * _drawerController.value;
              return Transform.translate(
                offset: Offset(-280 + slide, 0),
                child: child,
              );
            },
            child: CustomDrawer(
              onClose: _toggleDrawer,
              animationDuration: const Duration(milliseconds: 300),
              currentRoute: 'shift',
              onNavigate: _navigateTo,
            ),
          ),
        ],
      ),
    );
  }
}
