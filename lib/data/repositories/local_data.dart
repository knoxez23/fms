import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/animal.dart';
import '../models/crop.dart';
import '../models/task.dart';
import '../models/feeding_schedule.dart';
import '../models/feeding_log.dart';

class LocalData {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<Map<String, dynamic>> getFarmSummary() async {
    final db = await _dbHelper.database;

    // Get crop count
    final cropResult = await db.rawQuery('SELECT COUNT(*) as count FROM crops');
    final cropCount = Sqflite.firstIntValue(cropResult) ?? 0;

    // Get animal count
    final animalResult =
        await db.rawQuery('SELECT COUNT(*) as count FROM animals');
    final animalCount = Sqflite.firstIntValue(animalResult) ?? 0;

    // Get inventory count
    final inventoryResult =
        await db.rawQuery('SELECT COUNT(*) as count FROM inventory');
    final inventoryCount = Sqflite.firstIntValue(inventoryResult) ?? 0;

    // Get pending tasks count
    final tasksResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE status != "completed"');
    final pendingTasksCount = Sqflite.firstIntValue(tasksResult) ?? 0;

    // Get today's sales
    final today = DateTime.now().toIso8601String().split('T')[0];
    final salesResult = await db.rawQuery(
        'SELECT SUM(total_amount) as total FROM sales WHERE DATE(sale_date) = ?',
        [today]);
    final salesToday = (salesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Get this month's sales
    final firstDayOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1)
            .toIso8601String()
            .split('T')[0];
    final monthlySalesResult = await db.rawQuery(
        'SELECT SUM(total_amount) as total FROM sales WHERE DATE(sale_date) >= ?',
        [firstDayOfMonth]);
    final monthlySales =
        (monthlySalesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      "crops": cropCount,
      "livestock": animalCount,
      "inventory": inventoryCount,
      "pendingTasks": pendingTasksCount,
      "salesToday": salesToday,
      "monthlySales": monthlySales,
    };
  }

  static Future<List<Map<String, String>>> getMarketPrices() async {
    // For now, return cached or default data
    // In future, this will fetch from API and cache
    return [
      {"item": "Maize", "price": "Ksh 4,200 / 90kg bag"},
      {"item": "Beans", "price": "Ksh 6,000 / 90kg bag"},
      {"item": "Tomatoes", "price": "Ksh 2,800 / 90kg bag"},
      {"item": "Cabbages", "price": "Ksh 1,200 / 90kg bag"}
    ];
  }

  // Animal CRUD operations
  static Future<List<Animal>> getAnimals() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('animals');
    return List.generate(maps.length, (i) => Animal.fromMap(maps[i]));
  }

  static Future<int> insertAnimal(Animal animal) async {
    final db = await _dbHelper.database;
    return await db.insert('animals', animal.toMap());
  }

  static Future<int> upsertAnimal(Animal animal) async {
    final db = await _dbHelper.database;
    final map = animal.toMap();
    if (animal.id == null) {
      return await db.insert('animals', map);
    }
    return await db.insert(
      'animals',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateAnimal(Animal animal) async {
    final db = await _dbHelper.database;
    return await db.update(
      'animals',
      animal.toMap(),
      where: 'id = ?',
      whereArgs: [animal.id],
    );
  }

  static Future<int> deleteAnimal(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('animals', where: 'id = ?', whereArgs: [id]);
  }

  // Crop CRUD operations
  static Future<List<Crop>> getCrops() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('crops');
    return List.generate(maps.length, (i) => Crop.fromMap(maps[i]));
  }

  static Future<int> insertCrop(Crop crop) async {
    final db = await _dbHelper.database;
    return await db.insert('crops', crop.toMap());
  }

  static Future<int> upsertCrop(Crop crop) async {
    final db = await _dbHelper.database;
    final map = {
      'id': crop.id,
      ...crop.toMap(),
    };
    if (crop.id == null) {
      map.remove('id');
      return await db.insert('crops', map);
    }
    return await db.insert(
      'crops',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateCrop(Crop crop) async {
    final db = await _dbHelper.database;
    return await db.update(
      'crops',
      crop.toMap(),
      where: 'id = ?',
      whereArgs: [crop.id],
    );
  }

  static Future<int> deleteCrop(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('crops', where: 'id = ?', whereArgs: [id]);
  }

  // Task CRUD operations
  static Future<List<Task>> getTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  static Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  static Future<int> upsertTask(Task task) async {
    final db = await _dbHelper.database;
    final map = task.toMap();
    if (task.id == null) {
      return await db.insert('tasks', map);
    }
    return await db.insert(
      'tasks',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Feeding Schedule CRUD operations
  static Future<List<FeedingSchedule>> getFeedingSchedules() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('feeding_schedules');
    return List.generate(maps.length, (i) => FeedingSchedule.fromMap(maps[i]));
  }

  static Future<int> insertFeedingSchedule(FeedingSchedule schedule) async {
    final db = await _dbHelper.database;
    return await db.insert('feeding_schedules', schedule.toMap());
  }

  static Future<int> upsertFeedingSchedule(FeedingSchedule schedule) async {
    final db = await _dbHelper.database;
    final map = schedule.toMap();
    if (schedule.id == null) {
      return await db.insert('feeding_schedules', map);
    }
    return await db.insert(
      'feeding_schedules',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateFeedingSchedule(FeedingSchedule schedule) async {
    final db = await _dbHelper.database;
    return await db.update(
      'feeding_schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  static Future<int> deleteFeedingSchedule(int id) async {
    final db = await _dbHelper.database;
    return await db
        .delete('feeding_schedules', where: 'id = ?', whereArgs: [id]);
  }

  // Feeding Log CRUD operations
  static Future<List<FeedingLog>> getFeedingLogs() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('feeding_logs');
    return List.generate(maps.length, (i) => FeedingLog.fromMap(maps[i]));
  }

  static Future<int> insertFeedingLog(FeedingLog log) async {
    final db = await _dbHelper.database;
    return await db.insert('feeding_logs', log.toMap());
  }

  static Future<int> upsertFeedingLog(FeedingLog log) async {
    final db = await _dbHelper.database;
    final map = log.toMap();
    if (log.id == null) {
      return await db.insert('feeding_logs', map);
    }
    return await db.insert(
      'feeding_logs',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateFeedingLog(FeedingLog log) async {
    final db = await _dbHelper.database;
    return await db.update(
      'feeding_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  static Future<int> deleteFeedingLog(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('feeding_logs', where: 'id = ?', whereArgs: [id]);
  }

  // Sales CRUD operations
  static Future<List<Map<String, dynamic>>> getSales() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('sales', orderBy: 'sale_date DESC');
    return maps;
  }

  static Future<int> insertSale(Map<String, dynamic> sale) async {
    final db = await _dbHelper.database;

    // Ensure proper field mapping
    final row = <String, dynamic>{
      'server_id': sale['server_id'] ?? sale['id'],
      'product_name': sale['product_name'],
      'quantity': sale['quantity'],
      'unit': sale['unit'],
      'price': sale['price'],
      'total_amount': sale['total_amount'],
      'customer_name':
          sale['customer_name'] ?? sale['customer'], // Handle both formats
      'sale_date': sale['sale_date'] ?? sale['date'], // Handle both formats
      'payment_status': sale['payment_status'] ?? 'Pending',
      'notes': sale['notes'] ?? '',
      'user_id': sale['user_id'],
    };

    // Validate required fields
    if ((row['product_name'] as String?)?.trim().isEmpty ?? true) {
      throw Exception('Invalid sale: product_name is required');
    }
    if ((row['customer_name'] as String?)?.trim().isEmpty ?? true) {
      throw Exception('Invalid sale: customer_name is required');
    }

    return await db.insert('sales', row);
  }

  static Future<int> upsertSaleFromServer(Map<String, dynamic> sale) async {
    final db = await _dbHelper.database;
    final serverId = sale['id'];
    if (serverId == null) {
      return await insertSale(sale);
    }

    final row = <String, dynamic>{
      'server_id': serverId,
      'product_name': sale['product_name'],
      'quantity': sale['quantity'],
      'unit': sale['unit'],
      'price': sale['price'],
      'total_amount': sale['total_amount'],
      'customer_name': sale['customer_name'] ?? sale['customer'],
      'sale_date': sale['sale_date'] ?? sale['date'],
      'payment_status': sale['payment_status'] ?? 'Pending',
      'notes': sale['notes'] ?? '',
      'user_id': sale['user_id'],
    };

    final existing = await db.query(
      'sales',
      columns: ['id'],
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final localId = existing.first['id'] as int;
      await db.update('sales', row, where: 'id = ?', whereArgs: [localId]);
      return localId;
    }

    return await db.insert('sales', row);
  }

  static Future<int> updateSale(int id, Map<String, dynamic> sale) async {
    final db = await _dbHelper.database;

    final row = <String, dynamic>{
      'server_id': sale['server_id'] ?? sale['id'],
      'product_name': sale['product_name'],
      'quantity': sale['quantity'],
      'unit': sale['unit'],
      'price': sale['price'],
      'total_amount': sale['total_amount'],
      'customer_name': sale['customer_name'] ?? sale['customer'],
      'sale_date': sale['sale_date'] ?? sale['date'],
      'payment_status': sale['payment_status'] ?? 'Pending',
      'notes': sale['notes'] ?? '',
      'user_id': sale['user_id'],
    };

    return await db.update(
      'sales',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteSale(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int?> findSaleIdByPayload(Map<String, dynamic> sale) async {
    final db = await _dbHelper.database;

    final customerName = sale['customer_name'] ?? sale['customer'];
    final saleDate = sale['sale_date'] ?? sale['date'];

    final rows = await db.query(
      'sales',
      columns: ['id'],
      where:
          'product_name = ? AND quantity = ? AND unit = ? AND price = ? AND total_amount = ? AND customer_name = ? AND sale_date = ?',
      whereArgs: [
        sale['product_name'],
        sale['quantity'],
        sale['unit'],
        sale['price'],
        sale['total_amount'],
        customerName,
        saleDate,
      ],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  static Future<int?> findSaleIdByServerId(int serverId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'sales',
      columns: ['id'],
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  // Pending sales (offline sync queue)
  static Future<int> insertPendingSale(Map<String, dynamic> sale) async {
    if ((sale['product_name'] as String?)?.trim().isEmpty ?? true) {
      throw Exception('Cannot enqueue sale without product_name');
    }

    final db = await _dbHelper.database;
    return await db.insert(
      'pending_sales',
      {'payload': jsonEncode(sale)},
    );
  }

  static Future<List<Map<String, dynamic>>> getPendingSales() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('pending_sales', orderBy: 'created_at ASC');
    return maps;
  }

  static Future<int> deletePendingSale(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('pending_sales', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> cleanupInvalidSales() async {
    final db = await _dbHelper.database;

    final rows = await db.query('pending_sales');

    for (final row in rows) {
      final rawPayload = row['payload'] as String?;
      if (rawPayload == null) {
        await LocalData.deletePendingSale(row['id'] as int);
        continue;
      }

      final Map<String, dynamic> payload =
          jsonDecode(rawPayload) as Map<String, dynamic>;

      if ((payload['product_name'] as String?)?.trim().isEmpty ?? true) {
        await db.delete(
          'pending_sales',
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }
  }
}
