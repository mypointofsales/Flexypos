class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? note;
  final int isSynced;
  final String? updatedAt;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.note,
    this.isSynced = 0,
    this.updatedAt,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      note: map['note'],
      isSynced: map['is_synced'] ?? 0,
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'note': note,
      'is_synced': isSynced,
      'updated_at': updatedAt,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
