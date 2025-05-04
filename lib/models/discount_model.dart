class Discount {
  final int? id;
  final String name;
  final double value;
  final int isPercent;
  final String? updatedAt;
  final int? isSynced;

  Discount({
    this.id,
    required this.name,
    required this.value,
    this.isPercent = 1,
    this.updatedAt,
    this.isSynced,
  });

  factory Discount.fromMap(Map<String, dynamic> map) => Discount(
    id: map['id'],
    name: map['name'],
    value: (map['value'] as num).toDouble(),
    isPercent: map['is_percent'] ?? 1,
    updatedAt: map['updated_at'],
    isSynced: map['is_synced'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'value': value,
    'is_percent': isPercent,
    'updated_at': updatedAt,
    'is_synced': isSynced,
  };
}
