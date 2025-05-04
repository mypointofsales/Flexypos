import 'database_helper.dart';

class AuthService {
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await DatabaseHelper.instance.database;
    // Insert dummy user hanya untuk testing login
    await db.insert('user', {
      'username': '1',
      'password': '1',
      'role': 'admin',
    });
    final result = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty ? result.first : null;
  }
}
