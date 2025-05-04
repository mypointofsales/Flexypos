import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_helper.dart';
import '../screens/shift_screen.dart';
import '../screens/subscreens/sales_form_screen.dart';
import '../widgets/custom_drawer.dart';
import '../screens/welcome_screen.dart';
import '../screens/receipt_screen.dart';

import '../../widgets/settings_screen.dart';
import '../../widgets/item_screens.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecking = true;
  bool _isDrawerOpen = false;
  late AnimationController _drawerController;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkIfShiftIsOpen();
  }

  Future<void> _checkIfShiftIsOpen() async {
    final db = await DatabaseHelper.instance.database;

    final shift = await db.query(
      'shift',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (shift.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SaleFormScreen()),
        );
      });
    } else {
      setState(() {
        _isChecking = false;
      });
    }
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

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0A192F);

    return Scaffold(
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
                  title: Text(
                    'ticket'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: _toggleDrawer,
                  ),
                  actions: const [Icon(Icons.more_vert, color: Colors.white)],
                ),
              ),
            ),
          ),

          // ✅ Body
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 24),
            child:
                _isChecking
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.access_time_filled_sharp,
                              size: 150,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'shift_closed'.tr(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('open_shift_prompt'.tr()),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const ShiftScreen(
                                          afterOpenShift: 'sales',
                                        ),
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
                                'open_shift'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
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
              final slide = 280.0 * _drawerController.value;
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
}
