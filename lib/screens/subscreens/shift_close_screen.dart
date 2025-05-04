import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';
import '../shift_screen.dart';

class ShiftCloseScreen extends StatefulWidget {
  const ShiftCloseScreen({super.key});

  @override
  State<ShiftCloseScreen> createState() => _ShiftCloseScreenState();
}

class _ShiftCloseScreenState extends State<ShiftCloseScreen> {
  final TextEditingController _actualCashController = TextEditingController(
    text: '0',
  );

  int expectedCash = 0;
  int actualCash = 0;
  int? activeShiftId;

  int get difference => actualCash - expectedCash;

  @override
  void initState() {
    super.initState();
    _loadShiftData();
  }

  Future<void> _loadShiftData() async {
    final db = await DatabaseHelper.instance.database;
    final shift = await db.query(
      'shift',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (shift.isNotEmpty) {
      setState(() {
        activeShiftId = shift.first['id'] as int;
        expectedCash = shift.first['opening_cash'] as int;
      });
    }
  }

  void _onCashChanged(String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      actualCash = int.tryParse(clean) ?? 0;
    });
  }

  Future<void> _closeShift() async {
    if (activeShiftId == null) return;

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'shift',
      {
        'closing_cash': actualCash,
        'end_time': DateTime.now().toIso8601String(),
        'is_active': 0,
      },
      where: 'id = ?',
      whereArgs: [activeShiftId],
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('shift_closed_success'.tr())));
    // Navigasi ke ShiftScreen dan hapus semua route sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ShiftScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _actualCashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0A192F);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'close_shift'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('expected_cash_amount'.tr(), 'Rp$expectedCash'),
              const SizedBox(height: 24),

              Text(
                'actual_cash_amount'.tr(),
                style: const TextStyle(fontSize: 14),
              ),
              TextField(
                controller: _actualCashController,
                keyboardType: TextInputType.number,
                onChanged: _onCashChanged,
                decoration: const InputDecoration(hintText: 'Rp0'),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'difference'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp$difference',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: difference < 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _closeShift,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
