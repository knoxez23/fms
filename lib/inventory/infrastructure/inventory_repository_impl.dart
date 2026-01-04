import '../../../inventory/domain/repositories/inventory_repository.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<void> addItem(Map<String, dynamic> item) async {
    final db = await _dbHelper.database;
    await db.insert('inventory', {
      'item_name': item['name'] ?? item['item_name'],
      'category': item['category'],
      'quantity': item['quantity'],
      'unit': item['unit'],
      'unit_price': item['unit_price'],
      'total_value': item['total_value'],
      'supplier': item['supplier'],
      'expiry_date': item['expiry_date'],
      'last_updated': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete('inventory', where: 'id = ?', whereArgs: [int.tryParse(id)]);
  }

  @override
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('inventory');
    return maps.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  @override
  Future<void> updateItem(Map<String, dynamic> item) async {
    final db = await _dbHelper.database;
    final id = item['id'] is int ? item['id'] : int.tryParse('${item['id']}');
    if (id == null) return;
    await db.update(
      'inventory',
      {
        'item_name': item['name'] ?? item['item_name'],
        'category': item['category'],
        'quantity': item['quantity'],
        'unit': item['unit'],
        'unit_price': item['unit_price'],
        'total_value': item['total_value'],
        'supplier': item['supplier'],
        'expiry_date': item['expiry_date'],
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
