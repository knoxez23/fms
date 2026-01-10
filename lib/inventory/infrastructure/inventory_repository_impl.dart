import 'dart:developer' as developer;
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/models/inventory_dto.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/data/services/inventory_service.dart';
import 'package:pamoja_twalima/data/services/connectivity_service.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final InventoryService _inventoryService = InventoryService();
  final ConnectivityService _connectivity = ConnectivityService();

  // ---------- CREATE ----------
  @override
  Future<void> addItem(InventoryItem item) async {
    final db = await _dbHelper.database;
    final dto = InventoryDto.fromEntity(item);
    final localId = await db.insert('inventory', dto.toDb());

    developer.log('Added item to local DB with ID: $localId');

    await SyncDataRepository().queueInventoryAction(
      localId: localId,
      action: 'create',
      payload: dto.toApi(),
    );
  }

  // ---------- READ ----------
  @override
  Future<List<InventoryItem>> getItems() async {
    // Try to sync from server first if online
    final isOnline = await _connectivity.isOnline();
    if (isOnline) {
      try {
        await _syncFromServer();
      } catch (e) {
        developer.log('Failed to sync from server, using local data: $e');
      }
    }

    // Return local data
    final db = await _dbHelper.database;
    final maps = await db.query('inventory', orderBy: 'last_updated DESC');
    return maps.map(_mapToEntity).toList();
  }

  // ---------- SYNC FROM SERVER ----------
  Future<void> _syncFromServer() async {
    try {
      developer.log('Syncing inventory from server...');
      
      final serverItems = await _inventoryService.list();
      final db = await _dbHelper.database;

      for (final serverItem in serverItems) {
        final serverId = serverItem['id'];
        
        // Check if item already exists locally
        final existing = await db.query(
          'inventory',
          where: 'server_id = ?',
          whereArgs: [serverId],
          limit: 1,
        );

        final itemData = {
          'item_name': serverItem['item_name'],
          'category': serverItem['category'],
          'quantity': serverItem['quantity'],
          'unit': serverItem['unit'],
          'min_stock': serverItem['min_stock'] ?? 0,
          'unit_price': serverItem['unit_price'],
          'total_value': serverItem['total_value'],
          'supplier': serverItem['supplier'],
          'notes': serverItem['notes'],
          'last_restock': serverItem['last_restock'],
          'last_updated': serverItem['updated_at'] ?? DateTime.now().toIso8601String(),
          'is_synced': 1,
          'server_id': serverId,
          'conflict': 0,
        };

        if (existing.isEmpty) {
          // Insert new item
          await db.insert('inventory', itemData);
          developer.log('Inserted new item from server: ${serverItem['item_name']}');
        } else {
          // Update existing item if server version is newer
          final localItem = existing.first;
          final localUpdated = DateTime.tryParse(localItem['last_updated'] as String? ?? '');
          final serverUpdated = DateTime.tryParse(serverItem['updated_at'] as String? ?? '');

          if (serverUpdated != null && 
              (localUpdated == null || serverUpdated.isAfter(localUpdated))) {
            await db.update(
              'inventory',
              itemData,
              where: 'id = ?',
              whereArgs: [localItem['id']],
            );
            developer.log('Updated existing item from server: ${serverItem['item_name']}');
          }
        }
      }

      developer.log('Successfully synced ${serverItems.length} items from server');
    } catch (e, stackTrace) {
      developer.log('Error syncing from server: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
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
      lastRestock: row['last_restock'] != null
          ? DateTime.parse(row['last_restock'])
          : null,
      isSynced: (row['is_synced'] ?? 0) == 1,
      hasConflict: (row['conflict'] ?? 0) == 1,
    );
  }
}