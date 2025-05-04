import 'database_helper.dart';

class DBFunctions {
  /// Dapatkan ID shift aktif (is_active = 1)
  static Future<int?> getActiveShiftId() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'shift',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (result.isNotEmpty) return result.first['id'] as int;
    return null;
  }

  /// Dapatkan ID order draft terakhir yang sudah punya line
  static Future<int?> getActiveDraftOrderId(int shiftId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT so.id
      FROM sales_order so
      JOIN sales_order_line sol 
        ON sol.sales_order_id = so.id
      WHERE so.shift_id = ? AND so.status = 'draft'
      GROUP BY so.id
      ORDER BY so.created_at DESC
      LIMIT 1
      ''',
      [shiftId],
    );
    if (result.isNotEmpty) return result.first['id'] as int;
    return null;
  }

  /// Buat sales_order draft baru
  static Future<int> createInitialSalesOrder(
    int shiftId,
    int customerId,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final iso = now.toIso8601String();
    final orderNumber = 'SO-${now.microsecondsSinceEpoch}';
    return db.insert('sales_order', {
      'order_number': orderNumber,
      'created_at': iso,
      'updated_at': iso,
      'status': 'draft',
      'shift_id': shiftId,
      'total': 0,
      'total_tax': 0,
      'total_discount': 0,
      'customer_id': 0,
      'ticket_name': '',
      'comment': '',
    });
  }

  /// Tambah satu item ke sales_order_line
  /// - discountId = 0 artinya tanpa diskon
  /// - note = catatan per baris
  static Future<void> addProductToOrderLine({
    required int orderId,
    required int productId,
    required int quantity,
    required double price,
    required double cost,
    int discountId = 0,
    String note = '',
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    // 1. Ambil product untuk tax_id
    final pList = await db.query(
      'product',
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    final prod = pList.first;
    final int taxId = prod['tax_id'] as int? ?? 0;

    // 2. Ambil rate pajak (jika ada)
    double taxRate = 0;
    if (taxId != 0) {
      final tList = await db.query(
        'taxes',
        where: 'id = ?',
        whereArgs: [taxId],
        limit: 1,
      );
      if (tList.isNotEmpty) {
        taxRate = (tList.first['rate'] as num).toDouble();
      }
    }

    // 3. Ambil data diskon (jika ada)
    double discountRate = 0;
    double discountValue = 0;
    if (discountId != 0) {
      final dList = await db.query(
        'discounts',
        where: 'id = ?',
        whereArgs: [discountId],
        limit: 1,
      );
      if (dList.isNotEmpty) {
        final d = dList.first;
        discountRate = (d['value'] as num).toDouble();
        final isPercent = (d['is_percent'] as int?) ?? 1;
        final lineSubtotal = price * quantity;
        discountValue =
            isPercent == 1 ? lineSubtotal * discountRate / 100 : discountRate;
      }
    }

    // 4. Hitung subtotal & taxValue
    final subtotal = price * quantity;
    final taxValue = subtotal * taxRate / 100;

    // 5. Insert ke sales_order_line
    await db.insert('sales_order_line', {
      'sales_order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'cost': cost,
      'discount_id': discountId,
      'discount_rate': discountRate,
      'discount_value': discountValue,
      'tax_id': taxId,
      'tax_rate': taxRate,
      'tax_value': taxValue,
      'subtotal': subtotal,
      'note': note,
      'created_at': now,
      'updated_at': now,
    });

    // 6. Update header sales_order (total, total_tax, total_discount)
    final agg = await db.rawQuery(
      '''
      SELECT
        SUM(subtotal)       AS sum_total,
        SUM(tax_value)      AS sum_tax,
        SUM(discount_value) AS sum_discount
      FROM sales_order_line
      WHERE sales_order_id = ?
    ''',
      [orderId],
    );

    final sumTotal = (agg.first['sum_total'] as num?)?.toDouble() ?? 0;
    final sumTax = (agg.first['sum_tax'] as num?)?.toDouble() ?? 0;
    final sumDiscount = (agg.first['sum_discount'] as num?)?.toDouble() ?? 0;

    await db.update(
      'sales_order',
      {
        'total': sumTotal,
        'total_tax': sumTax,
        'total_discount': sumDiscount,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  /// Ambil semua lines beserta nama produk, pajak, diskon, subtotal
  static Future<List<Map<String, dynamic>>> getSalesOrderLines(
    int orderId,
  ) async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery(
      '''
      SELECT
        sol.*,
        p.name           AS product_name,
        sol.discount_rate,
        sol.discount_value,
        sol.tax_rate,
        sol.tax_value,
        sol.subtotal
      FROM sales_order_line sol
      JOIN product p ON p.id = sol.product_id
      WHERE sol.sales_order_id = ?
    ''',
      [orderId],
    );
  }

  /// Ambil lines untuk tampilan sederhana (nama + qty + price + cost)
  static Future<List<Map<String, dynamic>>> getSaleOrderLinesByOrderId(
    int orderId,
  ) async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery(
      '''
      SELECT
        sol.product_id,
        sol.quantity,
        sol.price,
        sol.cost,
        sol.discount_value,
        sol.tax_value,
        sol.tax_id,
        p.name
      FROM sales_order_line sol
      LEFT JOIN product p ON sol.product_id = p.id
      WHERE sol.sales_order_id = ?
    ''',
      [orderId],
    );
  }
}
