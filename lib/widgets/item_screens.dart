import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../screens/product_screen.dart';
import '../screens/category_screen.dart';
import '../screens/modifier_screen.dart';
import '../screens/discount_screen.dart';

import '../widgets/custom_drawer.dart';
import '../screens/welcome_screen.dart';
import '../screens/sales_screen.dart';
import '../screens/receipt_screen.dart';
import '../screens/shift_screen.dart';

import 'settings_screen.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen>
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
        case 'shift':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShiftScreen()),
          );
          break;
        case 'items':
          break; // sudah di sini
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

  Widget buildDivider() => const Divider(
    height: 1,
    thickness: 0.6,
    indent: 16,
    endIndent: 16,
    color: Color(0xFFB0BEC5), // abu-abu kebiruan elegan
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ AppBar sebagai background
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
                    'master_data_items'.tr(),
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
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.view_list,
                    color: Color(0xFF0A192F),
                  ),
                  title: Text(
                    'items'.tr(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductScreen()),
                    );
                  },
                ),
                buildDivider(),
                ListTile(
                  leading: const Icon(
                    Icons.grid_view_rounded,
                    color: Color(0xFF0A192F),
                  ),
                  title: Text(
                    'categories'.tr(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoryScreen()),
                    );
                  },
                ),
                buildDivider(),
                ListTile(
                  leading: const Icon(Icons.tune, color: Color(0xFF0A192F)),
                  title: Text(
                    'modifiers'.tr(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ModifierScreen()),
                    );
                  },
                ),
                buildDivider(),
                ListTile(
                  leading: const Icon(
                    Icons.local_offer,
                    color: Color(0xFF0A192F),
                  ),
                  title: Text(
                    'discounts'.tr(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DiscountScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // ✅ Overlay hitam saat drawer terbuka
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // ✅ Drawer yang menimpa AppBar + Body
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
              currentRoute: 'items',
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
