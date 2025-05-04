import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onClose;
  final Duration animationDuration;
  final String currentRoute;
  final Function(String routeName) onNavigate;

  const CustomDrawer({
    super.key,
    required this.onClose,
    required this.animationDuration,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 280,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.white,
            child: Column(
              children: [
                // Header drawer
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A192F),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kasir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'POS FLEXYPOS',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Administrator',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Menu
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildItem('sales', Icons.point_of_sale, 'Sales'),
                      _buildItem('receipts', Icons.receipt_long, 'Receipts'),
                      _buildItem('shift', Icons.access_time, 'Shift'),
                      _buildItem('items', Icons.view_list, 'Items'),
                      _buildItem('settings', Icons.settings, 'Settings'),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => onNavigate('logout'),
                      ),
                    ],
                  ),
                ),

                // Versi aplikasi
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('v.2.51', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListTile _buildItem(String route, IconData icon, String title) {
    final isSelected = route == currentRoute;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Color(0xFF0080FF) : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Color(0xFF0080FF) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? const Color(0xFFE3F2FD) : null,
      onTap: () => onNavigate(route),
    );
  }
}
