import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../widgets/custom_drawer.dart';
import '../screens/welcome_screen.dart';
import '../screens/sales_screen.dart';
import '../screens/shift_screen.dart';
import '../widgets/settings_screen.dart';
import '../widgets/item_screens.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _receipts = [];
  late AnimationController _drawerController;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadReceipts();
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
        case 'sales':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesScreen()),
          );
          break;
        case 'receipts':
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

  Future<void> _loadReceipts() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query('receipts', orderBy: 'receipt_time DESC');
    setState(() {
      _receipts = result;
    });
  }

  String _format(String? iso) {
    final dt = DateTime.tryParse(iso ?? '');
    return dt == null ? '-' : '${dt.day}/${dt.month} ${dt.hour}:${dt.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ AppBar di background
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
                  title: const Text(
                    'Daftar Receipt',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: _toggleDrawer,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Konten di bawah AppBar
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child:
                _receipts.isEmpty
                    ? const Center(child: Text('Belum ada receipt'))
                    : ListView.builder(
                      itemCount: _receipts.length,
                      itemBuilder: (_, i) {
                        final r = _receipts[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: const Icon(
                              Icons.receipt_long,
                              color: Color(0xFF0A192F),
                            ),
                            title: Text(
                              'Order ID: ${r['sales_order_id']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('Metode: ${r['payment_method']}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp ${r['total_paid']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _format(r['receipt_time']),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),

          // ✅ Overlay saat drawer dibuka
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // ✅ Drawer menimpa semua
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
              currentRoute: 'receipts',
              onNavigate: _navigateTo,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }
}
