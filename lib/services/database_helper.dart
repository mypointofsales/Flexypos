import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_schema.dart'; // ← Import schema

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flexypos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createAllTables(db);
        await insertDummyData(db);
      },
      onOpen: (db) async {
        await createAllTables(db);
        //await insertDummyData(db);
      },
    );
  }
}
