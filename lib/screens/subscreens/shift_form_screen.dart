import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_drawer.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/sales_screen.dart';
import '../../screens/receipt_screen.dart';
import '../../widgets/settings_screen.dart';
import '../../widgets/item_screens.dart';
import '../../screens/subscreens/shift_close_screen.dart';
import '../subscreens/cash_management_screen.dart';

class ShiftFormScreen extends StatefulWidget {
  const ShiftFormScreen({super.key});

  @override
  State<ShiftFormScreen> createState() => _ShiftFormScreenState();
}

class _ShiftFormScreenState extends State<ShiftFormScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReceiptScreen()),
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

  Widget _buildSectionTitle(String title, Color color) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.tr(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.tr(), style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ✅ AppBar Custom
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
                    'shift'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

          // ✅ Scrollable Body
          // ✅ Scrollable Body: Pastikan tidak ketiban AppBar
          Padding(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 48,
            ), // Tambah padding top
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ Tombol Cash Management
                  ElevatedButton(
                    // ✅ Tombol Cash Management
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CashManagementScreen(),
                        ),
                      );
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
                      'cash_management'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ✅ Tombol Close Shift
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShiftCloseScreen(),
                        ),
                      );
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
                      'close_shift'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ Info Shift
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'shift_number'.tr()}: 2'),
                      const SizedBox(height: 4),
                      Text('${'shift_opened'.tr()}: Kasir 4/18/25 18:32'),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildSectionTitle('cash_drawer', Colors.blue),
                  _buildRow('starting_cash', 'Rp0'),
                  _buildRow('cash_payments', 'Rp0'),
                  _buildRow('cash_refunds', 'Rp0'),
                  _buildRow('paid_in', 'Rp0'),
                  _buildRow('paid_out', 'Rp0'),
                  _buildRow('expected_cash_amount', 'Rp0'),
                  const Divider(height: 32),
                  _buildSectionTitle('sales_summary', Colors.blue),
                  _buildRow('gross_sales', 'Rp0'),
                  _buildRow('refunds', 'Rp0'),
                  _buildRow('discounts', 'Rp0'),
                  _buildRow('net_sales', 'Rp0'),
                  _buildRow('taxes', 'Rp0'),
                  _buildRow('total_tendered', 'Rp0'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ✅ Drawer Overlay
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // ✅ Drawer Panel
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
