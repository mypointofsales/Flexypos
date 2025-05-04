class User {
  final int? id;
  final String username;
  final String password;
  final String? role;

  User({this.id, required this.username, required this.password, this.role});

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    username: map['username'],
    password: map['password'],
    role: map['role'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role,
  };
}
