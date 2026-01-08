const String inventoryTable = 'inventories';

const String createInventoryTable = '''
CREATE TABLE $inventoryTable (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id INTEGER,
  item_name TEXT NOT NULL,
  category TEXT NOT NULL,
  quantity REAL NOT NULL,
  unit TEXT NOT NULL,
  min_stock INTEGER DEFAULT 0,
  supplier TEXT,
  unit_price REAL,
  total_value REAL,
  notes TEXT,
  last_restock TEXT,
  is_synced INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
''';
