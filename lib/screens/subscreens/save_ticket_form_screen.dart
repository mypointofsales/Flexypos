import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';
import '../../services/db_functions.dart';

class SaveTicketFormScreen extends StatefulWidget {
  final String initialName;
  final List<Map<String, dynamic>> products;
  final int orderId;
  final int customerId; // ⬅️ Tambahkan ini

  const SaveTicketFormScreen({
    super.key,
    required this.initialName,
    required this.products,
    required this.orderId,
    required this.customerId, // ⬅️ Tambahkan ini juga
  });

  @override
  State<SaveTicketFormScreen> createState() => _SaveTicketFormScreenState();
}

class _SaveTicketFormScreenState extends State<SaveTicketFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('Opening SaveTicketFormScreen');
    _nameController.text = widget.initialName;
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();

    if (name.isEmpty || widget.products.isEmpty) return;

    // Gunakan langsung widget.orderId
    final orderId = widget.orderId;

    for (var p in widget.products) {
      await DBFunctions.addProductToOrderLine(
        orderId: orderId,
        productId: p['product_id'],
        quantity: p['quantity'],
        price: p['price'],
        cost: p['cost'],
        discountId: p['discount_id'] ?? 0,
      );
    }
    double total = widget.products.fold(0.0, (sum, p) {
      final qty = p['quantity'] ?? 0;
      final price = p['price'] ?? 0;
      final discount = p['discount'] ?? 0;
      return sum + ((price * qty) - discount);
    });

    // Update sales_order dengan nama tiket dan komentar
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'sales_order',
      {
        'ticket_name': name,
        'comment': comment,
        'total': total, // ✅ penting!
        'updated_at': DateTime.now().toIso8601String(),
        'status': 'pending', // ✅ Ubah status jadi pending
        'customer_id': widget.customerId, // ✅ Simpan customer_id
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
    debugPrint('📝 Saving ticket with customerId: ${widget.customerId}');

    if (context.mounted) {
      Navigator.pop(context, {
        'order_id': orderId,
        'name': name,
        'comment': comment,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0A192F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: Text(
          'save_ticket'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              style: const TextStyle(fontSize: 16),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Comment',
                border: UnderlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
