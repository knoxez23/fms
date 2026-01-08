import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/models/inventory_dto.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ---------- CREATE ----------
  @override
  Future<void> addItem(InventoryItem item) async {
    final db = await _dbHelper.database;
    final dto = InventoryDto.fromEntity(item);

    final localId = await db.insert('inventory', dto.toDb());

    await SyncDataRepository().queueInventoryAction(
      localId: localId,
      action: 'create',
      payload: dto.toApi(),
    );
  }

  // ---------- READ ----------
  @override
  Future<List<InventoryItem>> getItems() async {
    final db = await _dbHelper.database;
    final maps = await db.query('inventory');

    return maps.map(_mapToEntity).toList();
  }

  // ---------- UPDATE ----------
  @override
  Future<void> updateItem(InventoryItem item) async {
    if (item.id == null) return;

    final db = await _dbHelper.database;
    final dto = InventoryDto.fromEntity(item);
    final localId = int.parse(item.id!);

    await db.update(
      'inventory',
      {
        ...dto.toDb(),
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );

    await SyncDataRepository().queueInventoryAction(
      localId: localId,
      action: 'update',
      payload: dto.toApi(),
    );
  }

  // ---------- DELETE ----------
  @override
  Future<void> deleteItem(String id) async {
    final db = await _dbHelper.database;
    final localId = int.parse(id);

    await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [localId],
    );

    await SyncDataRepository().queueInventoryAction(
      localId: localId,
      action: 'delete',
      payload: {},
    );
  }

  // ---------- PRIVATE MAPPER ----------
  InventoryItem _mapToEntity(Map<String, dynamic> row) {
    return InventoryItem(
      id: row['id']?.toString(),
      itemName: row['item_name'],
      category: row['category'],
      quantity: (row['quantity'] as num).toDouble(),
      unit: row['unit'],
      minStock: row['min_stock'] ?? 0,
      unitPrice: row['unit_price'] != null
          ? (row['unit_price'] as num).toDouble()
          : null,
      totalValue: row['total_value'] != null
          ? (row['total_value'] as num).toDouble()
          : null,
      supplier: row['supplier'],
      expiryDate: row['expiry_date'] != null
          ? DateTime.parse(row['expiry_date'])
          : null,
      lastUpdated: row['last_updated'] != null
          ? DateTime.parse(row['last_updated'])
          : null,
    );
  }
}
