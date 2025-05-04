class SalesOrderLine {
  final int? id;
  final int salesOrderId;
  final int productId;
  final int quantity;
  final double price;
  final double? cost;

  // Diskon per baris
  final int? discountId; // FK ke discounts.id
  final double? discountRate; // snapshot rate (persen atau nilai)
  final double? discountValue; // nominal diskon

  // Pajak per baris
  final int? taxId; // FK ke taxes.id
  final double? taxRate; // snapshot rate (%)
  final double? taxValue; // nominal pajak

  final double? subtotal; // sebelum pajak/diskon, atau sesuai kebutuhan
  final String? note;

  final String? createdAt;
  final String? updatedAt;

  SalesOrderLine({
    this.id,
    required this.salesOrderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.cost,
    this.discountId,
    this.discountRate,
    this.discountValue,
    this.taxId,
    this.taxRate,
    this.taxValue,
    this.subtotal,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory SalesOrderLine.fromMap(Map<String, dynamic> map) => SalesOrderLine(
    id: map['id'] as int?,
    salesOrderId: map['sales_order_id'] as int,
    productId: map['product_id'] as int,
    quantity: map['quantity'] as int,
    price: (map['price'] as num).toDouble(),
    cost: map['cost'] != null ? (map['cost'] as num).toDouble() : 0.0,
    discountId: map['discount_id'] as int?,
    discountRate:
        map['discount_rate'] != null
            ? (map['discount_rate'] as num).toDouble()
            : 0.0,
    discountValue:
        map['discount_value'] != null
            ? (map['discount_value'] as num).toDouble()
            : 0.0,
    taxId: map['tax_id'] as int?,
    taxRate:
        map['tax_rate'] != null ? (map['tax_rate'] as num).toDouble() : 0.0,
    taxValue:
        map['tax_value'] != null ? (map['tax_value'] as num).toDouble() : 0.0,
    subtotal:
        map['subtotal'] != null ? (map['subtotal'] as num).toDouble() : 0.0,
    note: map['note'] as String?,
    createdAt: map['created_at'] as String?,
    updatedAt: map['updated_at'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'sales_order_id': salesOrderId,
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
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
