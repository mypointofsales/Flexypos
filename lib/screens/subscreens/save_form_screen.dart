import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'save_ticket_form_screen.dart';

class SaveFormScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final int customerId; // ⬅️ Tambahkan ini

  const SaveFormScreen({
    super.key,
    required this.cart,
    required this.customerId, // ⬅️ Tambahkan ini
  });

  @override
  State<SaveFormScreen> createState() => _SaveFormScreenState();
}

class _SaveFormScreenState extends State<SaveFormScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customTicketName = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('Opening SaveFormScreen');
    if (!_initialized) {
      final now = TimeOfDay.now().format(context);
      _customTicketName.text = 'Ticket - $now';
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0A192F);
    final greenAccent = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(
          'save_ticket'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // 🔍 Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🟢 Label: Custom Ticket
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => SaveTicketFormScreen(
                        initialName: _customTicketName.text.trim(),
                        products: widget.cart, // ✅ PAKAI CART DARI DATABASE
                        orderId:
                            widget
                                .cart
                                .first['order_id'], // atau dari state currentOrderId
                        customerId: widget.customerId, // ✅ gunakan ini
                      ),
                ),
              );
              if (result != null && result.containsKey('order_id')) {
                Navigator.pop(context, result); // <- hasil berupa MAP, aman
              }
            },
            child: Center(
              child: Text(
                'CUSTOM TICKET',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          Center(
            child: Text(
              'all_tickets_used'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
