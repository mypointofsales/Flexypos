class Modifier {
  final int? id;
  final String? name;
  final String? options; // Comma separated options, ex: "Coklat,Keju,Susu"
  final String? updatedAt;
  final int isSynced;

  Modifier({
    this.id,
    this.name,
    this.options,
    this.updatedAt,
    this.isSynced = 0,
  });

  factory Modifier.fromMap(Map<String, dynamic> map) => Modifier(
    id: map['id'],
    name: map['name'],
    options: map['options'],
    updatedAt: map['updated_at'],
    isSynced: map['is_synced'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'options': options,
    'updated_at': updatedAt,
    'is_synced': isSynced,
  };
}
