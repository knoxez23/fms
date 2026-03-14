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

  Future<void> clearLocalSessionData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF');

      const tables = [
        'feeding_logs',
        'feeding_schedules',
        'production_logs',
        'animal_health_records',
        'breeding_records',
        'task_sync_queue',
        'task_delete_sync_queue',
        'inventory_sync_queue',
        'inventory_delete_tombstones',
        'pending_sales',
        'marketplace_inquiries',
        'sales',
        'expenses',
        'tasks',
        'inventory',
        'crops',
        'animals',
        'weather_cache',
        'market_prices_cache',
        'users',
      ];

      for (final table in tables) {
        await txn.delete(table);
      }

      await txn.execute('PRAGMA foreign_keys = ON');
    });
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pamoja_twalima.db');
    return await openDatabase(
      path,
      version: 25,
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
        client_uuid TEXT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority TEXT,
        status TEXT DEFAULT 'pending',
        category TEXT,
        assigned_to TEXT,
        staff_member_id INTEGER,
        source_event_type TEXT,
        source_event_id TEXT,
        completion_notes TEXT,
        approval_required INTEGER DEFAULT 0,
        approval_status TEXT DEFAULT 'not_required',
        approved_by TEXT,
        approved_at TEXT,
        approval_comment TEXT,
        is_synced INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Inventory table - WITH server_id column
    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_uuid TEXT,
        item_name TEXT NOT NULL,
        category TEXT,
        quantity REAL,
        unit TEXT,
        min_stock INTEGER DEFAULT 0,
        unit_price REAL,
        total_value REAL,
        supplier TEXT,
        supplier_id INTEGER,
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
        server_id INTEGER,
        product_name TEXT NOT NULL,
        type TEXT,
        quantity REAL,
        unit TEXT,
        price REAL,
        total_amount REAL,
        customer_name TEXT,
        customer_id INTEGER,
        sale_date TEXT DEFAULT CURRENT_TIMESTAMP,
        payment_status TEXT,
        notes TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        item_name TEXT NOT NULL,
        amount REAL NOT NULL,
        expense_date TEXT DEFAULT CURRENT_TIMESTAMP,
        vendor_name TEXT,
        payment_method TEXT,
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
        inventory_id INTEGER,
        feed_type TEXT NOT NULL,
        quantity REAL,
        unit TEXT,
        time_of_day TEXT,
        frequency TEXT,
        start_date TEXT,
        end_date TEXT,
        notes TEXT,
        completed INTEGER DEFAULT 0,
        user_id INTEGER,
        FOREIGN KEY (animal_id) REFERENCES animals (id),
        FOREIGN KEY (inventory_id) REFERENCES inventory (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Feeding logs table
    await db.execute('''
      CREATE TABLE feeding_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER,
        schedule_id INTEGER,
        inventory_id INTEGER,
        feed_type TEXT,
        quantity REAL,
        unit TEXT,
        fed_at TEXT DEFAULT CURRENT_TIMESTAMP,
        fed_by TEXT,
        notes TEXT,
        user_id INTEGER,
        FOREIGN KEY (animal_id) REFERENCES animals (id),
        FOREIGN KEY (schedule_id) REFERENCES feeding_schedules (id),
        FOREIGN KEY (inventory_id) REFERENCES inventory (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
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
        user_id INTEGER,
        FOREIGN KEY (animal_id) REFERENCES animals (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Animal health records table
    await db.execute('''
      CREATE TABLE animal_health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        notes TEXT,
        treated_at TEXT,
        user_id INTEGER,
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
        retry_count INTEGER DEFAULT 0,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Task delete sync queue table
    await db.execute('''
      CREATE TABLE task_delete_sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_server_id INTEGER NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Task create/update sync queue table
    await db.execute('''
      CREATE TABLE task_sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_local_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Inventory delete tombstones table
    await db.execute('''
      CREATE TABLE inventory_delete_tombstones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        inventory_local_id INTEGER,
        server_id INTEGER,
        client_uuid TEXT,
        deleted_at TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Pending sales table
    await db.execute('''
      CREATE TABLE pending_sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payload TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Marketplace inquiries table
    await db.execute('''
      CREATE TABLE marketplace_inquiries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        inquiry_type TEXT NOT NULL,
        product_name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity TEXT NOT NULL,
        details TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Breeding records table
    await db.execute('''
      CREATE TABLE breeding_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dam_animal_id INTEGER NOT NULL,
        sire_animal_id INTEGER,
        mating_date TEXT NOT NULL,
        expected_birth_date TEXT NOT NULL,
        status TEXT DEFAULT 'scheduled',
        method TEXT,
        success INTEGER,
        vet TEXT,
        notes TEXT,
        user_id INTEGER,
        FOREIGN KEY (dam_animal_id) REFERENCES animals (id),
        FOREIGN KEY (sire_animal_id) REFERENCES animals (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
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
        await db.execute(
            'ALTER TABLE inventory ADD COLUMN conflict INTEGER DEFAULT 0');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 6) {
      // Add client_uuid column to inventory table
      try {
        await db.execute('ALTER TABLE inventory ADD COLUMN client_uuid TEXT');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 7) {
      // Add marketplace inquiries table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS marketplace_inquiries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            inquiry_type TEXT NOT NULL,
            product_name TEXT NOT NULL,
            category TEXT NOT NULL,
            quantity TEXT NOT NULL,
            details TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      } catch (e) {
        // Table may already exist
      }
    }

    if (oldVersion < 8) {
      // Add breeding records table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS breeding_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dam_animal_id INTEGER NOT NULL,
            sire_animal_id INTEGER,
            mating_date TEXT NOT NULL,
            expected_birth_date TEXT NOT NULL,
            status TEXT DEFAULT 'scheduled',
            method TEXT,
            success INTEGER,
            vet TEXT,
            notes TEXT,
            FOREIGN KEY (dam_animal_id) REFERENCES animals (id),
            FOREIGN KEY (sire_animal_id) REFERENCES animals (id)
          )
        ''');
      } catch (e) {
        // Table may already exist
      }
    }

    if (oldVersion < 9) {
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN source_event_type TEXT');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN source_event_id TEXT');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 10) {
      try {
        await db.execute('ALTER TABLE sales ADD COLUMN server_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 11) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS animal_health_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            animal_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            name TEXT NOT NULL,
            notes TEXT,
            treated_at TEXT,
            user_id INTEGER,
            FOREIGN KEY (animal_id) REFERENCES animals (id)
          )
        ''');
      } catch (e) {
        // Table may already exist
      }
    }

    if (oldVersion < 12) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS inventory_delete_tombstones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            inventory_local_id INTEGER,
            server_id INTEGER,
            client_uuid TEXT,
            deleted_at TEXT NOT NULL,
            expires_at TEXT NOT NULL
          )
        ''');
      } catch (e) {
        // Table may already exist
      }
    }

    if (oldVersion < 17) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL,
            item_name TEXT NOT NULL,
            amount REAL NOT NULL,
            expense_date TEXT DEFAULT CURRENT_TIMESTAMP,
            vendor_name TEXT,
            payment_method TEXT,
            notes TEXT,
            user_id INTEGER,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
      } catch (e) {
        // Table may already exist
      }
    }

    if (oldVersion < 18) {
      try {
        await db.execute('ALTER TABLE sales ADD COLUMN type TEXT');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 19) {
      try {
        await db.execute(
            'ALTER TABLE feeding_schedules ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute('ALTER TABLE feeding_logs ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db
            .execute('ALTER TABLE production_logs ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 20) {
      try {
        await db.execute(
            'ALTER TABLE inventory_sync_queue ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute(
            'ALTER TABLE inventory_delete_tombstones ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db
            .execute('ALTER TABLE pending_sales ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute(
            'ALTER TABLE marketplace_inquiries ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 21) {
      try {
        await db.execute(
            'ALTER TABLE task_delete_sync_queue ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db
            .execute('ALTER TABLE task_sync_queue ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 22) {
      try {
        await db
            .execute('ALTER TABLE breeding_records ADD COLUMN user_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 23) {
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN client_uuid TEXT');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 24) {
      try {
        await db.execute(
            'ALTER TABLE tasks ADD COLUMN approval_required INTEGER DEFAULT 0');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute(
            "ALTER TABLE tasks ADD COLUMN approval_status TEXT DEFAULT 'not_required'");
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN approved_by TEXT');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN approved_at TEXT');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 25) {
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN completion_notes TEXT');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN approval_comment TEXT');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 13) {
      try {
        await db.execute(
            'ALTER TABLE tasks ADD COLUMN is_synced INTEGER DEFAULT 1');
      } catch (e) {
        // Column may already exist
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS task_delete_sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_server_id INTEGER NOT NULL UNIQUE,
            created_at TEXT NOT NULL,
            retry_count INTEGER DEFAULT 0
          )
        ''');
      } catch (e) {
        // Table may already exist
      }
    }

    if (oldVersion < 14) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS task_sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_local_id INTEGER NOT NULL,
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

    if (oldVersion < 15) {
      try {
        await db
            .execute('ALTER TABLE inventory ADD COLUMN supplier_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute('ALTER TABLE sales ADD COLUMN customer_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db
            .execute('ALTER TABLE tasks ADD COLUMN staff_member_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
    }

    if (oldVersion < 16) {
      try {
        await db.execute(
            'ALTER TABLE feeding_schedules ADD COLUMN inventory_id INTEGER');
      } catch (e) {
        // Column may already exist
      }
      try {
        await db.execute(
            'ALTER TABLE feeding_logs ADD COLUMN inventory_id INTEGER');
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
