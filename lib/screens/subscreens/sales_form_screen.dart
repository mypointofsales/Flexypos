// Full revised SaleFormScreen
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';
import '../../widgets/custom_drawer.dart';
import '../welcome_screen.dart';
import '../receipt_screen.dart';
import '../shift_screen.dart';
import '../../widgets/settings_screen.dart';
import '../../widgets/item_screens.dart';
import '../subscreens/barcode_scanner_screen.dart';
import '../subscreens/ticket_form_screen.dart';
import '../subscreens/save_form_screen.dart';
import '../subscreens/open_ticket_screen.dart';
import '../customer_screen.dart';
import '../../services/db_functions.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  bool _isDrawerOpen = false;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> _categories = [];
  String _selectedCategory = '0';
  String _searchQuery = '';
  String _viewType = 'list';
  final List<Map<String, dynamic>> _cart = [];
  int? _currentOrderId; // untuk simpan order aktif saat ini
  final bool _creatingOrder = false;
  bool _isFromOpenTicket = false;
  String? _ticketName;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCustomerId;
  String? _selectedCustomerName;

  @override
  void initState() {
    super.initState();
    debugPrint('Opening SaleFormScreen');
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
    _prepareNewOrder(); // ⬅️ Panggil saat pertama load
  }

  Future<void> _loadData() async {
    final db = await DatabaseHelper.instance.database;
    final products = await db.query('product');
    final categories = await db.query('category');
    final settings = await db.query('general_settings', limit: 1);

    if (settings.isNotEmpty) {
      _viewType = (settings.first['layout'] as String?) ?? 'list';
    }

    setState(() {
      _products = products;
      _categories = [
        {'id': 0, 'name': 'All'},
        ...categories,
      ];
      _selectedCategory = '0';
      _filteredProducts = products;
    });
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      _isDrawerOpen ? _drawerController.forward() : _drawerController.reverse();
    });
  }

  void _navigateTo(String route) {
    _toggleDrawer();
    Future.delayed(const Duration(milliseconds: 300), () {
      switch (route) {
        case 'receipts':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReceiptScreen()),
          );
          break;
        case 'shift':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShiftScreen()),
          );
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

  Future<void> _loadTicketName(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'sales_order',
      columns: ['ticket_name'],
      where: 'id = ?',
      whereArgs: [orderId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      setState(() {
        _ticketName = result.first['ticket_name']?.toString();
      });
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts =
          _products.where((p) {
            final matchesCategory =
                _selectedCategory == '0' ||
                p['category_id'].toString() == _selectedCategory;

            final name = p['name'].toString().toLowerCase();
            final barcode = p['barcode']?.toString().toLowerCase() ?? '';

            final matchesSearch =
                name.contains(_searchQuery.toLowerCase()) ||
                barcode.contains(_searchQuery.toLowerCase());

            return matchesCategory && matchesSearch;
          }).toList();
    });
  }

  Future<void> _prepareNewOrder() async {
    print('🟡 _prepareNewOrder called');

    if (_currentOrderId != null) {
      print('ℹ️ Order sudah disiapkan sebelumnya: $_currentOrderId');
      return;
    }

    final db = await DatabaseHelper.instance.database;
    final shiftResult = await db.query(
      'shift',
      where: 'is_active = 1',
      limit: 1,
    );

    if (shiftResult.isNotEmpty) {
      final shiftId = shiftResult.first['id'] as int;

      // ✅ Cek apakah sudah ada sales_order draft di shift ini
      final existingDraft = await db.query(
        'sales_order',
        where: 'shift_id = ? AND status = ?',
        whereArgs: [shiftId, 'draft'],
        limit: 1,
      );

      if (existingDraft.isNotEmpty) {
        final existingOrderId = existingDraft.first['id'] as int;
        setState(() {
          _currentOrderId = existingOrderId;
        });
        print('♻️ Gunakan sales_order draft yang sudah ada: $_currentOrderId');
        return;
      }
      print(
        '🟡 _prepareNewOrder: shift=$shiftId, customerId=$_selectedCustomerId',
      );

      // ❌ Belum ada draft → buat baru
      final newOrderId = await createInitialSalesOrder(
        shiftId: shiftId,
        customerId: _selectedCustomerId ?? 0,
        products: [],
      );

      setState(() {
        _currentOrderId = newOrderId;
      });

      print('✅ Draft sales_order baru dibuat: $_currentOrderId');
    } else {
      print('❌ Tidak ada shift aktif');
    }
  }

  //sale_order

  Future<int> createInitialSalesOrder({
    required int shiftId,
    required int customerId,
    required List<Map<String, dynamic>> products, // biasanya _cart
  }) async {
    final orderId = await DBFunctions.createInitialSalesOrder(
      shiftId,
      customerId,
    );
    debugPrint('🟢 Creating sales_order with customerId: $customerId');

    // 2) Masukkan setiap item pakai DBFunctions.addProductToOrderLine()
    for (var item in products) {
      await DBFunctions.addProductToOrderLine(
        orderId: orderId,
        productId: item['product_id'] as int,
        quantity: item['quantity'] as int,
        price: item['price'] as double,
        cost: (item['cost'] as num?)?.toDouble() ?? 0.0,
        // jika pakai diskon: discountId: item['discountId'] as int? ?? 0,
        note: item['note'] as String? ?? '',
      );
    }

    return orderId;
  }

  Future<void> _saveEditedOrder() async {
    debugPrint('🔁 Menyimpan order ID $_currentOrderId via _saveEditedOrder');
    if (_currentOrderId == null) return;
    final orderId = _currentOrderId!;

    // 2. Hapus semua baris lama di sales_order_line
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'sales_order_line',
      where: 'sales_order_id = ?',
      whereArgs: [orderId],
    );

    // 3. Insert ulang semua item dari _cart
    for (var item in _cart) {
      await DBFunctions.addProductToOrderLine(
        orderId: orderId,
        productId: item['product_id'] as int,
        quantity: item['quantity'] as int,
        price: item['price'] as double,
        cost: (item['cost'] as num?)?.toDouble() ?? 0.0,
        // kalau nanti ada diskon per item, tambahkan:
        // discountId: item['discountId'] as int? ?? 0,
        note: item['note'] as String? ?? '',
      );
    }

    // 4. Reset state: kosongkan cart dan keluar dari mode open ticket
    setState(() {
      _cart.clear();
      _isFromOpenTicket = false;
      _currentOrderId = null;
      _ticketName = null;
      // ⬇️ Tambahkan baris ini:
      _selectedCustomerId = null;
      _selectedCustomerName = null;
    });

    // 5. Buat draft order baru untuk transaksi selanjutnya
    await _prepareNewOrder();

    // 6. Tampilkan konfirmasi ke user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Order berhasil diperbarui')),
    );
  }

  Future<List<Map<String, dynamic>>> getOpenTicketsWithProducts() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
    SELECT 
      so.id AS order_id,
      so.ticket_name,
      so.total,
      so.created_at,
      GROUP_CONCAT(p.name, ', ') AS products
    FROM sales_order so
    LEFT JOIN sales_order_line sol ON so.id = sol.sales_order_id
    LEFT JOIN product p ON sol.product_id = p.id
    WHERE so.status = 'pending'
    GROUP BY so.id
    ORDER BY so.created_at DESC
  ''');

    return result.map((row) {
      final createdAt =
          DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now();
      final duration = DateTime.now().difference(createdAt);

      final fallbackName = 'Ticket - ${DateFormat.Hm().format(createdAt)}';
      final name =
          (row['ticket_name']?.toString().isNotEmpty == true)
              ? row['ticket_name'].toString()
              : fallbackName;

      final subtitle = '${duration.inHours}h ${duration.inMinutes % 60}m ago';

      return {
        'id': row['order_id'],
        'name': name,
        'subtitle': subtitle,
        'total': row['total'] ?? 0,
        'products': row['products'] ?? '', // 🔥 daftar nama produk!
        'created_at': row['created_at'], // <-- ini penting
      };
    }).toList();
  }

  Color? _getCardColorFromId(dynamic categoryId) {
    final cat = _categories.firstWhere(
      (c) => c['id'].toString() == categoryId.toString(),
      orElse: () => {},
    );

    final hexColor = cat['color']?.toString();

    if (hexColor == null || hexColor.isEmpty) return Colors.grey[200];

    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xff')));
    } catch (_) {
      return Colors.grey[200]; // fallback
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0A192F);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: themeColor,
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
                  title: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => TicketFormScreen(
                                cart: List<Map<String, dynamic>>.from(_cart),
                                customerId: _selectedCustomerId ?? 0,
                              ),
                        ),
                      );

                      if (result != null) {
                        final status = result['status'];
                        final cartFromTicket = result['cart'] as List<dynamic>?;

                        if (status == 'updated' || status == 'new') {
                          setState(() {
                            _cart.clear();
                            _cart.addAll(
                              cartFromTicket?.cast<Map<String, dynamic>>() ??
                                  [],
                            );
                            _currentOrderId = result['order_id'];

                            _isFromOpenTicket = true;
                          });
                          await _loadTicketName(
                            _currentOrderId!,
                          ); // ⬅️ Tambahkan ini
                          await _saveEditedOrder();
                        } else if (status == 'restored') {
                          debugPrint(
                            '🔁 Ticket dibuka dan cart di-restore TANPA disimpan ulang',
                          );
                          debugPrint(
                            '🟨 order_id: ${result['order_id']}, cartLen: ${cartFromTicket?.length}',
                          );
                          setState(() {
                            _cart.clear();
                            _cart.addAll(
                              cartFromTicket?.cast<Map<String, dynamic>>() ??
                                  [],
                            );
                            _isFromOpenTicket = true;
                            _currentOrderId = result['order_id'] as int?;
                          });
                        } else if (status == 'cancel') {
                          debugPrint(
                            '❌ Ticket dibatalkan, cart direstore dan status di-reset',
                          );
                          setState(() {
                            _cart.clear();
                            _cart.addAll(
                              cartFromTicket?.cast<Map<String, dynamic>>() ??
                                  [],
                            );
                            //_isFromOpenTicket = true;
                            //_currentOrderId = null;
                          });
                        }

                        debugPrint(
                          '⬅️ Kembali dari TicketFormScreen dengan status: ${result['status']}',
                        );
                        debugPrint(
                          '➡️ Cart length: ${_cart.length}, isFromOpenTicket: $_isFromOpenTicket, orderId: $_currentOrderId',
                        );
                      } else {
                        debugPrint(
                          '❌ Back dari TicketFormScreen tanpa perubahan',
                        );
                      }
                    },

                    child: Row(
                      children: [
                        Text(
                          _ticketName != null && _ticketName!.isNotEmpty
                              ? '$_ticketName'
                              : 'ticket'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),

                        const SizedBox(width: 4),
                        if (_cart.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(color: Colors.white),
                            child: Text(
                              '${_cart.fold<int>(0, (sum, item) => sum + (item['quantity'] as int))}', // 🔥 Total kuantitas
                              style: TextStyle(
                                color: themeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: _toggleDrawer,
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        _selectedCustomerId != null
                            ? Icons
                                .check_circle // ✅ Tampilkan icon checklist
                            : Icons.person_add_alt, // default icon
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final selectedCustomer =
                            await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomerScreen(),
                              ),
                            );

                        if (selectedCustomer != null) {
                          setState(() {
                            _selectedCustomerId = selectedCustomer['id'];
                            _selectedCustomerName = selectedCustomer['name'];
                          });
                          debugPrint(
                            '✅ Customer selected: ID=$_selectedCustomerId, Name=$_selectedCustomerName',
                          );
                        } else {
                          debugPrint('❌ No customer selected');
                        }
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 22),

                  // Top Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_cart.isNotEmpty) {
                                  if (_isFromOpenTicket) {
                                    // ➡️ Ini kalau dari Open Ticket, langsung update
                                    await _saveEditedOrder();
                                    debugPrint('💾 Klik tombol SAVE');
                                    debugPrint(
                                      '🧾 isFromOpenTicket: $_isFromOpenTicket, cart: ${_cart.length}, orderId: $_currentOrderId',
                                    );

                                    setState(() {
                                      _cart.clear();
                                      _currentOrderId = null;
                                      _isFromOpenTicket = false; // reset lagi
                                    });
                                    await _prepareNewOrder();
                                  } else {
                                    // ➡️ Ini kalau dari buat order baru, masuk SaveTicketFormScreen
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => SaveFormScreen(
                                              cart: _cart,
                                              customerId:
                                                  _selectedCustomerId ?? 0,
                                            ),
                                      ),
                                    );

                                    if (result != null &&
                                        result['order_id'] != null) {
                                      final savedOrderId =
                                          result['order_id'] as int;

                                      setState(() {
                                        _cart.clear();
                                        _currentOrderId = null;
                                        _isFromOpenTicket = false; // reset lagi
                                      });
                                      _ticketName = null;
                                      await _prepareNewOrder();

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '✅ Ticket saved: ${result['name']}',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  // Kalau cart kosong, masuk ke Open Ticket
                                  final openTickets =
                                      await getOpenTicketsWithProducts();
                                  final selectedOrderId =
                                      await Navigator.push<int>(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => OpenTicketScreen(
                                                tickets: openTickets,
                                              ),
                                        ),
                                      );

                                  if (selectedOrderId != null) {
                                    final lines =
                                        await DBFunctions.getSaleOrderLinesByOrderId(
                                          selectedOrderId,
                                        );
                                    await _loadTicketName(
                                      selectedOrderId,
                                    ); // ⬅️ Tambahkan ini
                                    setState(() {
                                      _currentOrderId = selectedOrderId;
                                      _isFromOpenTicket = true; // ➡️ Tambah ini
                                      _cart.clear();

                                      for (var line in lines) {
                                        _cart.add({
                                          'product_id': line['product_id'],
                                          'name':
                                              line['name'] ??
                                              '', // 🔥 sekarang ada isinya!
                                          'price': line['price'],
                                          'cost': line['cost'],
                                          'quantity': line['quantity'],
                                          'note': line['note'],
                                          'order_id': selectedOrderId,
                                          'taxId': line['tax_id'],
                                        });
                                      }
                                    });
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
                                    _cart.isNotEmpty
                                        ? 'save'.tr()
                                        : 'open_tickets'.tr(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    '',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
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
                                    'charge'.tr(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rp${_cart.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity'])).toStringAsFixed(0)}',

                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  FutureBuilder(
                    future: DatabaseHelper.instance.database.then((db) async {
                      final setting = await db.query(
                        'general_settings',
                        limit: 1,
                      );
                      return setting.isNotEmpty &&
                          setting.first['use_camera'] == 1;
                    }),
                    builder: (context, snapshot) {
                      final showCamera = snapshot.data == true;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child:
                                    !_isSearching
                                        ? DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value:
                                                _categories.any(
                                                      (cat) =>
                                                          cat['id']
                                                              .toString() ==
                                                          _selectedCategory,
                                                    )
                                                    ? _selectedCategory
                                                    : null,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedCategory =
                                                    value ?? '0';
                                                _filterProducts();
                                              });
                                            },
                                            items:
                                                _categories
                                                    .map(
                                                      (cat) => DropdownMenuItem<
                                                        String
                                                      >(
                                                        value:
                                                            cat['id']
                                                                .toString(),
                                                        child: Text(
                                                          cat['name'],
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        )
                                        : TextField(
                                          controller: _searchController,
                                          autofocus: true,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: const InputDecoration(
                                            hintText: 'Cari produk...',
                                            isDense: true,
                                            border: InputBorder.none,
                                            prefixIcon: Icon(Icons.search),
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              _searchQuery = val;
                                              _filterProducts();
                                            });
                                          },
                                        ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isSearching ? Icons.close : Icons.search,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isSearching = !_isSearching;
                                    if (!_isSearching) {
                                      _searchQuery = '';
                                      _searchController.clear();
                                      _filterProducts();
                                    }
                                  });
                                },
                              ),
                              if (showCamera)
                                IconButton(
                                  icon: const Icon(Icons.qr_code_scanner),
                                  onPressed: () async {
                                    final scanned = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => BarcodeScannerScreen(
                                              onScanned: (String code) {
                                                setState(() {
                                                  _searchQuery = code;
                                                  _searchController.text = code;
                                                  _filterProducts();
                                                });
                                              },
                                            ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Product Grid/List
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child:
                          _viewType == 'grid'
                              ? GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (_, i) {
                                  final item = _filteredProducts[i];
                                  return GestureDetector(
                                    onTap: () {
                                      final existingIndex = _cart.indexWhere(
                                        (p) => p['product_id'] == item['id'],
                                      );
                                      setState(() {
                                        if (existingIndex >= 0) {
                                          _cart[existingIndex]['quantity'] += 1;
                                        } else {
                                          _cart.add({
                                            'product_id': item['id'],
                                            'name': item['name'],
                                            'price': item['price'],
                                            'cost': item['cost'] ?? 0,
                                            'quantity': 1,
                                            'note': '',
                                            'order_id': _currentOrderId,
                                            'taxId':
                                                item['tax_id'], // ✅ ambil default tax dari product
                                          });
                                        }
                                      });
                                    },
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      color: _getCardColorFromId(
                                        item['category_id'],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              item['name'],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              currencyFormat.format(
                                                item['price'],
                                              ),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : ListView.separated(
                                itemCount: _filteredProducts.length,
                                separatorBuilder:
                                    (_, __) => const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final item = _filteredProducts[i];
                                  return ListTile(
                                    title: Text(item['name']),
                                    trailing: Text(
                                      currencyFormat.format(item['price']),
                                    ),
                                    onTap: () {
                                      final existingIndex = _cart.indexWhere(
                                        (p) => p['product_id'] == item['id'],
                                      );
                                      setState(() {
                                        if (existingIndex >= 0) {
                                          _cart[existingIndex]['quantity'] += 1;
                                        } else {
                                          _cart.add({
                                            'product_id': item['id'],
                                            'name': item['name'],
                                            'price': item['price'],
                                            'cost': item['cost'] ?? 0,
                                            'quantity': 1,
                                            'note': '',
                                            'order_id':
                                                _currentOrderId, // penting untuk referensi
                                            'taxId':
                                                item['tax_id'], // ✅ ambil default tax dari product
                                          });
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_cart.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                'Cart is empty',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
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
              currentRoute: 'sales',
              onNavigate: _navigateTo,
            ),
          ),
        ],
      ),
    );
  }

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
}
