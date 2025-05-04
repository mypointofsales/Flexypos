import '../../models/customer_model.dart';
import 'database_helper.dart';

class CustomerService {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertCustomer(Customer customer) async {
    final db = await dbHelper.database;
    return await db.insert('customer', customer.toMap());
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await dbHelper.database;
    final result = await db.query('customer', orderBy: 'updated_at DESC');
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('customer', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Customer.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await dbHelper.database;
    return await db.update(
      'customer',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await dbHelper.database;
    return await db.delete('customer', where: 'id = ?', whereArgs: [id]);
  }
}
