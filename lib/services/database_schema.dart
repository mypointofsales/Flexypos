import 'package:sqflite/sqflite.dart';

Future<void> createAllTables(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      password TEXT,
      role TEXT
    )
  ''');

  await db.execute('''
      CREATE TABLE IF NOT EXISTS product (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        cost REAL,
        stock INTEGER NOT NULL,
        sku TEXT,
        barcode TEXT,
        category_id INTEGER,
        track_stock INTEGER DEFAULT 0,
        sold_by TEXT,
        modifier_ids TEXT,
        tax_id INTEGER DEFAULT 0,
        color TEXT,
        shape TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

  await db.execute('''
      CREATE TABLE IF NOT EXISTS category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS shift (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shift_name TEXT,
      start_time TEXT,
      end_time TEXT,
      opening_cash INTEGER,
      closing_cash INTEGER,
      is_active INTEGER
    )
  ''');

  await db.execute('''
      CREATE TABLE IF NOT EXISTS modifiers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        options TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS sales_order (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      order_number    TEXT,
      created_at      TEXT,
      updated_at      TEXT,
      status          TEXT,    -- draft, paid, cancelled
      shift_id        INTEGER,
      total           REAL     DEFAULT 0,
      total_tax       REAL     DEFAULT 0,    -- snapshot total pajak
      total_discount  REAL     DEFAULT 0,    -- snapshot total diskon
      customer_id     INTEGER, 
      ticket_name     TEXT,   -- untuk menyimpan nama tiket/manual/meja
      comment         TEXT    -- komentar tambahan dari user
    )
  ''');

  // Tabel sales_order_line: tambah kolom pajak & diskon
  await db.execute('''
    CREATE TABLE IF NOT EXISTS sales_order_line (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      sales_order_id  INTEGER,
      product_id      INTEGER,
      quantity        INTEGER DEFAULT 1,
      price           REAL,                   -- harga jual satuan
      cost            REAL,                   -- harga modal satuan

      -- diskon per baris
      discount_id     INTEGER DEFAULT 0,      -- FK ke discounts.id
      discount_rate   REAL    DEFAULT 0,      -- persentase atau nilai di‐snapshot
      discount_value  REAL    DEFAULT 0,      -- nominal diskon yang terpakai

      -- pajak per baris
      tax_id          INTEGER DEFAULT 0,      -- FK ke taxes.id
      tax_rate        REAL    DEFAULT 0,      -- rate pajak yang terpakai
      tax_value       REAL    DEFAULT 0,      -- nominal pajak yang terhitung

      subtotal        REAL    DEFAULT 0,      -- sebelum pajak / diskon, atau sesuaikan
      note            TEXT,

      created_at      TEXT,
      updated_at      TEXT
    )
  ''');

  await db.execute('''
      CREATE TABLE IF NOT EXISTS receipts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sales_order_id INTEGER,
        total_paid REAL,
        payment_method TEXT,
        receipt_time TEXT
      )
    ''');
  await db.execute('''
      CREATE TABLE IF NOT EXISTS general_settings (
        id INTEGER PRIMARY KEY,
        use_camera INTEGER,
        dark_mode TEXT DEFAULT 'system',
        layout TEXT,
        language_mode TEXT DEFAULT 'system'
      )
    ''');

  await db.execute('''
      CREATE TABLE IF NOT EXISTS discounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        value REAL,
        is_percent INTEGER DEFAULT 1,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

  await db.execute('''
      CREATE TABLE IF NOT EXISTS printers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        model TEXT,
        print_receipt INTEGER,
        print_order INTEGER,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

  await db.execute('''
      CREATE TABLE IF NOT EXISTS taxes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        rate REAL,
        type TEXT,
        item_count INTEGER DEFAULT 0,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS customer (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      address TEXT,
      note TEXT,
      is_synced INTEGER DEFAULT 0,
      updated_at TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS cash_transaction (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shift_id INTEGER,
    amount REAL NOT NULL,
    type TEXT NOT NULL, -- 'in' atau 'out'
    comment TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  ) 
  ''');
}

Future<void> insertDummyData(Database db) async {
  // Insert Categories
  await db.insert('category', {
    'name': 'Makanan',
    'color': '#FF5733',
    'updated_at': '2024-01-01 10:00:00',
    'is_synced': 1,
  });
  await db.insert('category', {
    'name': 'Minuman',
    'color': '#33B5FF',
    'updated_at': '2024-01-01 10:00:00',
    'is_synced': 1,
  });
  await db.insert('category', {
    'name': 'Snack',
    'color': '#FFC300',
    'updated_at': '2024-01-01 10:00:00',
    'is_synced': 1,
  });

  // Insert Modifiers
  await db.insert('modifiers', {
    'name': 'Topping',
    'options': 'Coklat,Keju,Susu',
    'updated_at': '2024-01-01 10:00:00',
    'is_synced': 1,
  });
  await db.insert('modifiers', {
    'name': 'Ukuran',
    'options': 'Small,Medium,Large',
    'updated_at': '2024-01-01 10:00:00',
    'is_synced': 1,
  });

  // Color options (dipakai sebagai warna product)
  final List<String> colorOptions = [
    '#F5F5F5', // Light Gray
    '#FFCDD2', // Soft Red
    '#F8BBD0', // Soft Pink
    '#FFE0B2', // Soft Orange
    '#F0F4C3', // Soft Lime
    '#C8E6C9', // Soft Green
    '#BBDEFB', // Soft Blue
    '#E1BEE7', // Soft Purple
  ];

  // Insert 6 Products (menggunakan 'tax_id' sesuai schema baru)
  await db.insert('product', {
    'name': 'Nasi Goreng',
    'price': 20000.0,
    'cost': 12000.0,
    'stock': 50,
    'sku': 'SKU001',
    'barcode': 'BR001',
    'category_id': 1,
    'track_stock': 1,
    'sold_by': 'pcs',
    'modifier_ids': '1',
    'tax_id': 1,
    'color': colorOptions[0],
    'shape': 'square',
    'updated_at': '2024-01-01 10:00:00',
    'is_synced': 1,
  });

  await db.insert('customer', {
    'name': 'Boy',
    'phone': '08123456789',
    'email': 'boy@example.com',
    'address': 'Jl. Melati No.1',
    'note': 'Pelanggan loyal',
    'updated_at': '2024-01-01 10:00:00',
    'is_synced': 1,
  });

  await db.insert('product', {
    'name': 'Es Teh Manis',
    'price': 8000.0,
    'cost': 3000.0,
    'stock': 100,
    'sku': 'SKU002',
    'barcode': 'BR002',
    'category_id': 2,
    'track_stock': 1,
    'sold_by': 'pcs',
    'modifier_ids': '2',
    'tax_id': 0,
    'color': colorOptions[1],
    'shape': 'circle',
    'updated_at': '2024-01-01 10:00:00',
    'is_synced': 1,
  });
}
