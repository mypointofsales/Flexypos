class Category {
  final int? id;
  final String name;
  final String? color;
  final String? updatedAt;
  final int isSynced;

  Category({
    this.id,
    required this.name,
    this.color,
    this.updatedAt,
    this.isSynced = 0,
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'],
    name: map['name'],
    color: map['color'],
    updatedAt: map['updated_at'],
    isSynced: map['is_synced'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color': color,
    'updated_at': updatedAt,
    'is_synced': isSynced,
  };
}
