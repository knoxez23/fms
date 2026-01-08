class InventorySyncQueueTable {
  static const tableName = 'inventory_sync_queue';

  static const createTable = '''
  CREATE TABLE $tableName (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    inventory_local_id INTEGER,
    action TEXT NOT NULL, -- create | update | delete
    payload TEXT NOT NULL,
    created_at TEXT NOT NULL,
    retry_count INTEGER DEFAULT 0
  )
  ''';
}
