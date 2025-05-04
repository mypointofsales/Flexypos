import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../screens/printer_screen.dart';
import '../screens/tax_screen.dart';
import '../screens/general_screen.dart';
import '../widgets/custom_drawer.dart';
import '../screens/welcome_screen.dart';
import '../screens/sales_screen.dart';
import '../screens/receipt_screen.dart';
import '../screens/shift_screen.dart';
import 'item_screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ItemScreen()),
          );
          break;
        case 'settings':
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
    color: Color(0xFFB0BEC5),
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
                    'settings'.tr(),
                    style: const TextStyle(
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
                  leading: const Icon(Icons.print, color: Color(0xFF0A192F)),
                  title: Text(
                    'printers'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('printer_subtitle'.tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrinterScreen()),
                    );
                  },
                ),
                buildDivider(),
                ListTile(
                  leading: const Icon(Icons.percent, color: Color(0xFF0A192F)),
                  title: Text(
                    'taxes'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('tax_subtitle'.tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TaxScreen()),
                    );
                  },
                ),
                buildDivider(),
                ListTile(
                  leading: const Icon(Icons.settings, color: Color(0xFF0A192F)),
                  title: Text(
                    'general'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('general_subtitle'.tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GeneralScreen()),
                    );
                  },
                ),
                buildDivider(),
              ],
            ),
          ),

          // ✅ Overlay hitam saat drawer terbuka
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // ✅ Drawer
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
              currentRoute: 'settings',
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
