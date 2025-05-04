class Product {
  final int? id;
  final String name;
  final double price;
  final double? cost;
  final int stock;
  final String? sku;
  final String? barcode;
  final int? categoryId;
  final int trackStock;
  final String? soldBy;
  final String? modifierIds;

  // dulu: int tax;
  // sekarang pakai FK ke taxes.id
  final int taxId;

  final String? color;
  final String? shape;
  final String? updatedAt;
  final int isSynced;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.cost,
    required this.stock,
    this.sku,
    this.barcode,
    this.categoryId,
    this.trackStock = 0,
    this.soldBy,
    this.modifierIds,
    this.taxId = 0, // default 0 = no tax
    this.color,
    this.shape,
    this.updatedAt,
    this.isSynced = 0,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    // fallback ke kunci 'tax' jika belum migrasi, tapi utamakan 'tax_id'
    final dynamic raw = map['tax_id'] ?? map['tax'] ?? 0;
    final int tid = raw is int ? raw : int.tryParse(raw.toString()) ?? 0;

    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      cost: map['cost'] != null ? (map['cost'] as num).toDouble() : null,
      stock: map['stock'] as int,
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      categoryId: map['category_id'] as int?,
      trackStock: map['track_stock'] as int? ?? 0,
      soldBy: map['sold_by'] as String?,
      modifierIds: map['modifier_ids'] as String?,
      taxId: tid,
      color: map['color'] as String?,
      shape: map['shape'] as String?,
      updatedAt: map['updated_at'] as String?,
      isSynced: map['is_synced'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'cost': cost,
    'stock': stock,
    'sku': sku,
    'barcode': barcode,
    'category_id': categoryId,
    'track_stock': trackStock,
    'sold_by': soldBy,
    'modifier_ids': modifierIds,
    'tax_id': taxId, // pakai tax_id sekarang
    'color': color,
    'shape': shape,
    'updated_at': updatedAt,
    'is_synced': isSynced,
  };
}
