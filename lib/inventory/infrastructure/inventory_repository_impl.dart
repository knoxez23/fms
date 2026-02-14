import 'dart:convert';
import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/models/inventory_dto.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/data/services/inventory_service.dart';
import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/services/connectivity_service.dart';

@LazySingleton(as: InventoryRepository)
class InventoryRepositoryImpl implements InventoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final InventoryService _inventoryService;
  final ConnectivityService _connectivity;

  InventoryRepositoryImpl(this._inventoryService, this._connectivity);

  // ---------- CREATE ----------
  @override
  Future<void> addItem(InventoryItem item) async {
    final db = await _dbHelper.database;
    final clientUuid = item.clientUuid ?? const Uuid().v4();
    final dto = InventoryDto.fromEntity(
      InventoryItem(
        id: item.id,
        clientUuid: clientUuid,
        itemName: item.itemName,
        category: item.category,
        quantity: item.quantity,
        unit: item.unit,
        minStock: item.minStock,
        unitPrice: item.unitPrice,
        totalValue: item.totalValue,
        supplier: item.supplier,
        expiryDate: item.expiryDate,
        lastRestock: item.lastRestock,
        isSynced: item.isSynced,
        hasConflict: item.hasConflict,
      ),
    );
    final localId = await db.insert('inventory', {
      ...dto.toDb(),
      'last_updated': DateTime.now().toIso8601String(),
      'conflict': 0,
    });

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
      final pendingDeleteServerIds = await _getPendingDeleteServerIds(db);
      final pendingDeleteClientUuids = await _getPendingDeleteClientUuids(db);
      final pendingActionLocalIds = await _getPendingActionLocalIds(db);
      final seenServerIds = <int>{};

      for (final serverItem in serverItems) {
        final serverId = serverItem['id'];
        final serverClientUuid = serverItem['client_uuid'];

        if (serverId == null) {
          continue;
        }
        if (serverId is int) {
          seenServerIds.add(serverId);
        }

        if (pendingDeleteServerIds.contains(serverId)) {
          developer.log('Skipping server item $serverId due to pending delete');
          continue;
        }
        if (serverClientUuid != null &&
            pendingDeleteClientUuids.contains(serverClientUuid.toString())) {
          developer.log(
            'Skipping server item $serverId due to pending delete client_uuid=$serverClientUuid',
          );
          continue;
        }

        // Check if item already exists locally
        List<Map<String, dynamic>> existing = await db.query(
          'inventory',
          where: 'server_id = ?',
          whereArgs: [serverId],
          limit: 1,
        );

        if (existing.isEmpty && serverClientUuid != null) {
          existing = await db.query(
            'inventory',
            where: 'client_uuid = ?',
            whereArgs: [serverClientUuid],
            limit: 1,
          );
        }

        final itemData = {
          'client_uuid': serverClientUuid,
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
          'last_updated':
              serverItem['updated_at'] ?? DateTime.now().toIso8601String(),
          'is_synced': 1,
          'server_id': serverId,
          'conflict': 0,
        };

        if (existing.isEmpty) {
          // Insert new item
          await db.insert('inventory', itemData);
          developer
              .log('Inserted new item from server: ${serverItem['item_name']}');
        } else {
          // Update existing item if server version is newer
          final localItem = existing.first;
          final localIsSynced = (localItem['is_synced'] ?? 0) == 1;
          final localUpdated =
              DateTime.tryParse(localItem['last_updated'] as String? ?? '');
          final serverUpdated =
              DateTime.tryParse(serverItem['updated_at'] as String? ?? '');

          if (!localIsSynced &&
              serverUpdated != null &&
              (localUpdated == null || serverUpdated.isAfter(localUpdated))) {
            // Keep local unsynced edits and flag for manual conflict resolution.
            await db.update(
              'inventory',
              {
                'server_id': localItem['server_id'] ?? serverId,
                'client_uuid': localItem['client_uuid'] ?? serverClientUuid,
                'conflict': 1,
              },
              where: 'id = ?',
              whereArgs: [localItem['id']],
            );
            developer.log(
              'Detected conflict for local item ${localItem['id']} (server newer while local unsynced)',
            );
          } else if (serverUpdated != null &&
              (localUpdated == null || serverUpdated.isAfter(localUpdated))) {
            await db.update(
              'inventory',
              itemData,
              where: 'id = ?',
              whereArgs: [localItem['id']],
            );
            developer.log(
                'Updated existing item from server: ${serverItem['item_name']}');
          } else if (localItem['server_id'] == null && serverId != null) {
            // Preserve local edits; only attach server_id to avoid duplicates later.
            await db.update(
              'inventory',
              {
                'server_id': serverId,
                'client_uuid': serverClientUuid,
              },
              where: 'id = ?',
              whereArgs: [localItem['id']],
            );
          }
        }
      }

      // Reconcile local rows that still reference removed server records.
      final localSyncedRows = await db.query(
        'inventory',
        columns: ['id', 'server_id', 'is_synced'],
        where: 'server_id IS NOT NULL',
      );
      for (final row in localSyncedRows) {
        final localId = row['id'] as int?;
        final serverId = row['server_id'] as int?;
        if (localId == null || serverId == null) {
          continue;
        }
        if (seenServerIds.contains(serverId) ||
            pendingActionLocalIds.contains(localId)) {
          continue;
        }

        final isSynced = (row['is_synced'] ?? 0) == 1;
        if (isSynced) {
          await db.delete('inventory', where: 'id = ?', whereArgs: [localId]);
          developer.log(
            'Removed local inventory $localId because server row $serverId no longer exists',
          );
        } else {
          await db.update(
            'inventory',
            {'conflict': 1},
            where: 'id = ?',
            whereArgs: [localId],
          );
          developer.log(
            'Marked local inventory $localId as conflict because server row $serverId is missing',
          );
        }
      }

      developer
          .log('Successfully synced ${serverItems.length} items from server');
    } catch (e, stackTrace) {
      developer.log('Error syncing from server: $e',
          error: e, stackTrace: stackTrace);
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
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 0,
        'conflict': 0,
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
    int? serverId;
    String? clientUuid;
    bool wasSynced = false;

    final existing = await db.query(
      'inventory',
      columns: ['server_id', 'client_uuid', 'is_synced'],
      where: 'id = ?',
      whereArgs: [localId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      serverId = existing.first['server_id'] as int?;
      clientUuid = existing.first['client_uuid'] as String?;
      wasSynced = (existing.first['is_synced'] ?? 0) == 1;
    }

    // Prevent stale create/update queue entries from replaying deleted rows.
    await SyncDataRepository().removeInventoryActionsForLocalId(localId);

    await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [localId],
    );

    if (serverId == null &&
        (!wasSynced || clientUuid == null || clientUuid.isEmpty)) {
      // If item has no remote identity, there is nothing to delete on server.
      return;
    }

    final payload = <String, dynamic>{};
    if (serverId != null) {
      payload['server_id'] = serverId;
    }
    if (clientUuid != null && clientUuid.isNotEmpty) {
      payload['client_uuid'] = clientUuid;
    }

    await SyncDataRepository().queueInventoryAction(
      localId: localId,
      action: 'delete',
      payload: payload,
    );
  }

  @override
  Future<void> resolveConflictKeepLocal(String localId) async {
    final db = await _dbHelper.database;
    final localIntId = int.parse(localId);

    final existing = await db.query(
      'inventory',
      where: 'id = ?',
      whereArgs: [localIntId],
      limit: 1,
    );
    if (existing.isEmpty) return;

    final row = existing.first;
    final serverId = row['server_id'] as int?;
    final payload = _dbRowToApiPayload(row);
    payload['client_uuid'] = row['client_uuid'];

    await db.update(
      'inventory',
      {
        'is_synced': 0,
        'conflict': 0,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localIntId],
    );

    await SyncDataRepository().removeInventoryActionsForLocalId(localIntId);
    await SyncDataRepository().queueInventoryAction(
      localId: localIntId,
      action: serverId == null ? 'create' : 'update',
      payload: payload,
    );
  }

  @override
  Future<void> resolveConflictUseServer(String localId) async {
    final db = await _dbHelper.database;
    final localIntId = int.parse(localId);

    final existing = await db.query(
      'inventory',
      columns: ['server_id'],
      where: 'id = ?',
      whereArgs: [localIntId],
      limit: 1,
    );
    if (existing.isEmpty) return;

    final serverId = existing.first['server_id'] as int?;
    if (serverId == null) return;

    final serverItem = await _inventoryService.get(serverId);
    await db.update(
      'inventory',
      {
        'client_uuid': serverItem['client_uuid'],
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
        'last_updated':
            serverItem['updated_at'] ?? DateTime.now().toIso8601String(),
        'is_synced': 1,
        'conflict': 0,
      },
      where: 'id = ?',
      whereArgs: [localIntId],
    );

    await SyncDataRepository().removeInventoryActionsForLocalId(localIntId);
  }

  Future<Set<int>> _getPendingDeleteServerIds(Database db) async {
    final rows = await db.query(
      'inventory_sync_queue',
      columns: ['payload', 'action'],
      where: 'action = ?',
      whereArgs: ['delete'],
    );

    final ids = <int>{};
    for (final row in rows) {
      final payloadStr = row['payload'] as String?;
      if (payloadStr == null) continue;
      try {
        final payload = Map<String, dynamic>.from(
          jsonDecode(payloadStr) as Map,
        );
        final serverId = payload['server_id'];
        if (serverId is int) {
          ids.add(serverId);
        } else if (serverId is String) {
          final parsed = int.tryParse(serverId);
          if (parsed != null) ids.add(parsed);
        }
      } catch (_) {
        // Ignore malformed payloads
      }
    }

    return ids;
  }

  Future<Set<String>> _getPendingDeleteClientUuids(Database db) async {
    final rows = await db.query(
      'inventory_sync_queue',
      columns: ['payload', 'action'],
      where: 'action = ?',
      whereArgs: ['delete'],
    );

    final uuids = <String>{};
    for (final row in rows) {
      final payloadStr = row['payload'] as String?;
      if (payloadStr == null) continue;
      try {
        final payload = Map<String, dynamic>.from(
          jsonDecode(payloadStr) as Map,
        );
        final clientUuid = payload['client_uuid'];
        if (clientUuid is String && clientUuid.isNotEmpty) {
          uuids.add(clientUuid);
        }
      } catch (_) {
        // Ignore malformed payloads
      }
    }

    return uuids;
  }

  Future<Set<int>> _getPendingActionLocalIds(Database db) async {
    final rows = await db.query(
      'inventory_sync_queue',
      columns: ['inventory_local_id'],
    );

    return rows
        .map((row) => row['inventory_local_id'])
        .whereType<int>()
        .toSet();
  }

  // ---------- PRIVATE MAPPER ----------
  InventoryItem _mapToEntity(Map<String, dynamic> row) {
    return InventoryItem(
      id: row['id']?.toString(),
      clientUuid: row['client_uuid'],
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

  Map<String, dynamic> _dbRowToApiPayload(Map<String, dynamic> row) {
    return {
      'client_uuid': row['client_uuid'],
      'item_name': row['item_name'],
      'category': row['category'],
      'quantity': row['quantity'],
      'unit': row['unit'],
      'min_stock': row['min_stock'] ?? 0,
      'supplier': row['supplier'],
      'unit_price': row['unit_price'],
      'total_value': row['total_value'],
      'notes': row['notes'],
      'last_restock': row['last_restock'],
    };
  }
}
