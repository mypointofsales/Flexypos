import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/database_helper.dart';

class CashManagementScreen extends StatefulWidget {
  const CashManagementScreen({super.key});

  @override
  State<CashManagementScreen> createState() => _CashManagementScreenState();
}

class _CashManagementScreenState extends State<CashManagementScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'cash_transaction',
      orderBy: 'created_at DESC',
      where: 'shift_id = ?',
      whereArgs: [1], // ganti dengan shift aktif
    );
    setState(() {
      _transactions = result;
    });
  }

  Future<void> insertCashTransaction({
    required double amount,
    required String type,
    String? comment,
    int? shiftId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('cash_transaction', {
      'shift_id': shiftId ?? 1,
      'amount': amount,
      'type': type,
      'comment': comment ?? '',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  void _handleTransaction(String type) async {
    final amountText = _amountController.text.trim();
    final comment = _commentController.text.trim();
    final amount = double.tryParse(
      amountText.replaceAll(RegExp(r'[^\d.]'), ''),
    );

    if (amount == null || amount <= 0) return;

    await insertCashTransaction(
      amount: amount,
      type: type,
      comment: comment,
      shiftId: 1,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          type == 'in' ? 'pay_in_success'.tr() : 'pay_out_success'.tr(),
        ),
      ),
    );

    _amountController.clear();
    _commentController.clear();

    await _loadTransactions();
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  String _formatTime(String isoString) {
    final dateTime = DateTime.tryParse(isoString);
    if (dateTime == null) return '';
    return DateFormat.Hm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0A192F);

    return Scaffold(
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
                  title: Text(
                    'cash_management'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 24),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'amount'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Rp0',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'comment'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: '',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () => _handleTransaction('in'),
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
                      'pay_in'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () => _handleTransaction('out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      'pay_out'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transaction List
                  if (_transactions.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'pay_in_out_history'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._transactions.map((tx) {
                          final isOut = tx['type'] == 'out';
                          final nominal = _formatCurrency(tx['amount']);
                          final amountDisplay = isOut ? '-$nominal' : nominal;

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_formatTime(tx['created_at'])}  Kasir - ${tx['comment'] ?? ''}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    amountDisplay,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isOut ? Colors.red : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                            ],
                          );
                        }),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
