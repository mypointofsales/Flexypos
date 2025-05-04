import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/database_helper.dart';

class ApiService {
  static const String baseUrl =
      "http://100.80.42.35:8080/api"; // GANTI jika di HP/vps

  // GET ALL PRODUCTS
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load products');
  }

  // CREATE PRODUCT
  Future<bool> createProduct(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );
    return response.statusCode == 200;
  }

  // UPDATE PRODUCT
  Future<bool> updateProduct(int id, Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );
    return response.statusCode == 200;
  }

  // DELETE PRODUCT
  Future<bool> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    return response.statusCode == 200;
  }

  // Tambah fungsi ini di ApiService
  Future<void> batchUpsertProducts(List<Map<String, dynamic>> products) async {
    final url = Uri.parse('$baseUrl/products/batch');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(products),
    );
    if (response.statusCode != 200) {
      throw Exception('Sync failed: ${response.body}');
    }
  }

  // GET ALL CATEGORIES
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load categories');
  }

  Future<void> batchUpsertCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    final url = Uri.parse('$baseUrl/categories/batch');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'categories': categories}),
    );

    if (res.statusCode != 200) {
      throw Exception('Sync failed: ${res.body}');
    }
  }

  // CRUD kategori mirip (tinggal ganti endpoint)
  Future<void> syncTable({
    required String table,
    required Future<List<Map<String, dynamic>>> Function() getServerData,
    required Future<void> Function(List<Map<String, dynamic>> list)
    pushLocalBatch,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // 1️⃣ PUSH DULU
    final unsynced = await db.query(table, where: 'is_synced = 0');
    if (unsynced.isNotEmpty) {
      await pushLocalBatch(unsynced);
      for (final row in unsynced) {
        await db.update(
          table,
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }

    // 2️⃣ Lalu PULL, replace lokal
    final serverData = await getServerData();
    await db.delete(table);
    for (final row in serverData) {
      await db.insert(table, row);
    }
  }
}
