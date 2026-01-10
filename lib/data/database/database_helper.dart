import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pamoja_twalima.db');
    return await openDatabase(
      path,
      version: 5, // INCREMENTED VERSION
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        farm_name TEXT,
        location TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Animals table
    await db.execute('''
      CREATE TABLE animals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        breed TEXT,
        age INTEGER,
        weight REAL,
        health_status TEXT,
        date_acquired TEXT,
        notes TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Crops table
    await db.execute('''
      CREATE TABLE crops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        variety TEXT,
        planted_date TEXT,
        expected_harvest_date TEXT,
        area REAL,
        status TEXT,
        notes TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority TEXT,
        status TEXT DEFAULT 'pending',
        category TEXT,
        assigned_to TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Inventory table - WITH server_id column
    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        category TEXT,
        quantity REAL,
        unit TEXT,
        min_stock INTEGER DEFAULT 0,
        unit_price REAL,
        total_value REAL,
        supplier TEXT,
        notes TEXT,
        last_restock TEXT,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
        is_synced INTEGER DEFAULT 0,
        server_id INTEGER,
        conflict INTEGER DEFAULT 0,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT NOT NULL,
        quantity REAL,
        unit TEXT,
        price REAL,
        total_amount REAL,
        customer_name TEXT,
        sale_date TEXT DEFAULT CURRENT_TIMESTAMP,
        payment_status TEXT,
        notes TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Feeding schedules table
    await db.execute('''
      CREATE TABLE feeding_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER,
        feed_type TEXT NOT NULL,
        quantity REAL,
        unit TEXT,
        time_of_day TEXT,
        frequency TEXT,
        start_date TEXT,
        end_date TEXT,
        notes TEXT,
        completed INTEGER DEFAULT 0,
        FOREIGN KEY (animal_id) REFERENCES animals (id)
      )
    ''');

    // Feeding logs table
    await db.execute('''
      CREATE TABLE feeding_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER,
        schedule_id INTEGER,
        feed_type TEXT,
        quantity REAL,
        unit TEXT,
        fed_at TEXT DEFAULT CURRENT_TIMESTAMP,
        fed_by TEXT,
        notes TEXT,
        FOREIGN KEY (animal_id) REFERENCES animals (id),
        FOREIGN KEY (schedule_id) REFERENCES feeding_schedules (id)
      )
    ''');

    // Production logs table
    await db.execute('''
      CREATE TABLE production_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER,
        production_type TEXT NOT NULL,
        quantity REAL,
        unit TEXT,
        date_produced TEXT DEFAULT CURRENT_TIMESTAMP,
        quality_rating INTEGER,
        notes TEXT,
        FOREIGN KEY (animal_id) REFERENCES animals (id)
      )
    ''');

    // Weather cache table
    await db.execute('''
      CREATE TABLE weather_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location TEXT,
        data TEXT,
        fetched_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Market prices cache table
    await db.execute('''
      CREATE TABLE market_prices_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item TEXT,
        price TEXT,
        location TEXT,
        fetched_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Inventory sync queue table
    await db.execute('''
      CREATE TABLE inventory_sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        inventory_local_id INTEGER,
        action TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Pending sales table
    await db.execute('''
      CREATE TABLE pending_sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payload TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add pending_sales table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          payload TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }

    if (oldVersion < 4) {
      // Add inventory_sync_queue table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS inventory_sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            inventory_local_id INTEGER,
            action TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at TEXT NOT NULL,
            retry_count INTEGER DEFAULT 0
          )
        ''');
      } catch (e) {
        // Table may already exist
      }
    }

    if (oldVersion < 5) {
      // Add server_id and conflict columns to inventory table
      try {
        await db.execute('ALTER TABLE inventory ADD COLUMN server_id INTEGER');
      } catch (e) {
        // Column may already exist
      }

      try {
        await db.execute('ALTER TABLE inventory ADD COLUMN conflict INTEGER DEFAULT 0');
      } catch (e) {
        // Column may already exist
      }
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}