class Tax {
  final int? id;
  final String name;
  final double rate;
  final String? type;
  final int? itemCount;
  final String? updatedAt;
  final int? isSynced;

  Tax({
    this.id,
    required this.name,
    required this.rate,
    this.type,
    this.itemCount,
    this.updatedAt,
    this.isSynced,
  });

  factory Tax.fromMap(Map<String, dynamic> map) => Tax(
    id: map['id'],
    name: map['name'],
    rate: (map['rate'] as num).toDouble(),
    type: map['type'],
    itemCount: map['item_count'],
    updatedAt: map['updated_at'],
    isSynced: map['is_synced'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'rate': rate,
    'type': type,
    'item_count': itemCount,
    'updated_at': updatedAt,
    'is_synced': isSynced,
  };
}
