import 'dart:convert';
import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';

class InventorySyncWorker {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _api = ApiService();

  Future<void> sync() async {
    developer.log('InventorySyncWorker: Starting inventory sync');

    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> queue = await db.query(
      'inventory_sync_queue',
      orderBy: 'created_at ASC',
    );

    developer.log('InventorySyncWorker: Found ${queue.length} items to sync');

    if (queue.isEmpty) {
      developer.log('InventorySyncWorker: No items to sync');
      return;
    }

    int successCount = 0;
    int failCount = 0;

    for (final item in queue) {
      try {
        await _processItem(db, item);
        successCount++;
      } catch (e, stackTrace) {
        failCount++;
        developer.log(
          'InventorySyncWorker: Failed to process item ${item['id']}: $e',
          error: e,
          stackTrace: stackTrace,
        );

        // Increment retry count
        final retryCount = (item['retry_count'] as int? ?? 0) + 1;

        if (retryCount >= 3) {
          // After 3 retries, mark as failed and skip
          developer.log(
              'InventorySyncWorker: Max retries reached for item ${item['id']}, removing from queue');
          await db.delete(
            'inventory_sync_queue',
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          // Update retry count
          await db.update(
            'inventory_sync_queue',
            {'retry_count': retryCount},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }

        // Don't break - continue trying other items
      }
    }

    developer.log(
        'InventorySyncWorker: Sync completed - Success: $successCount, Failed: $failCount');
  }

  Future<void> _processItem(
    Database db,
    Map<String, dynamic> queueItem,
  ) async {
    final String action = queueItem['action'];
    final String payloadStr = queueItem['payload'] as String;
    final int localId = queueItem['inventory_local_id'];

    developer
        .log('InventorySyncWorker: Processing $action for local_id=$localId');
    developer.log('InventorySyncWorker: Payload: $payloadStr');

    Map<String, dynamic> payload;
    try {
      payload = Map<String, dynamic>.from(jsonDecode(payloadStr));
    } catch (e) {
      developer.log('InventorySyncWorker: Invalid JSON payload: $e');
      throw Exception('Invalid payload JSON');
    }

    // Validate required fields before sending (skip for delete)
    if (action != 'delete' && !_validatePayload(payload)) {
      developer.log(
          'InventorySyncWorker: Invalid payload - missing required fields');
      // Remove invalid entry from queue
      await db.delete(
        'inventory_sync_queue',
        where: 'id = ?',
        whereArgs: [queueItem['id']],
      );
      return;
    }

    try {
      if (action == 'create') {
        developer.log('InventorySyncWorker: POSTing to /inventories');

        final response = await _api.post(
          '/inventories',
          data: payload,
        );

        developer.log(
            'InventorySyncWorker: Create successful, response: ${response.data}');

        final int newServerId = response.data['id'];
        await _markSynced(db, localId, newServerId);
      } else if (action == 'update') {
        // Get server_id from inventory table
        final inventoryRecord = await db.query(
          'inventory',
          where: 'id = ?',
          whereArgs: [localId],
        );

        if (inventoryRecord.isEmpty) {
          developer.log(
              'InventorySyncWorker: Local record not found for id=$localId');
          await db.delete(
            'inventory_sync_queue',
            where: 'id = ?',
            whereArgs: [queueItem['id']],
          );
          return;
        }

        final serverId = inventoryRecord.first['server_id'] as int?;

        if (serverId != null) {
          developer
              .log('InventorySyncWorker: PUTing to /inventories/$serverId');

          await _api.put(
            '/inventories/$serverId',
            data: payload,
          );

          developer.log('InventorySyncWorker: Update successful');
          await _markSynced(db, localId, serverId);
        } else {
          developer
              .log('InventorySyncWorker: No server_id found, cannot update');
          throw Exception('Missing server_id for update');
        }
      } else if (action == 'delete') {
        int? serverId;
        String? clientUuid;
        final rawServerId = payload['server_id'];
        final rawClientUuid = payload['client_uuid'];
        if (rawServerId is int) {
          serverId = rawServerId;
        } else if (rawServerId is String) {
          serverId = int.tryParse(rawServerId);
        }
        if (rawClientUuid is String && rawClientUuid.isNotEmpty) {
          clientUuid = rawClientUuid;
        }

        // Fallback: get server_id from inventory table
        final inventoryRecord = await db.query(
          'inventory',
          columns: ['server_id', 'client_uuid'],
          where: 'id = ?',
          whereArgs: [localId],
        );

        if (serverId == null && inventoryRecord.isNotEmpty) {
          serverId = inventoryRecord.first['server_id'] as int?;
          clientUuid ??= inventoryRecord.first['client_uuid'] as String?;
        }

        if (serverId != null) {
          developer
              .log('InventorySyncWorker: DELETEing /inventories/$serverId');
          await _api.delete('/inventories/$serverId');
          developer.log('InventorySyncWorker: Delete successful');
        } else if (clientUuid != null) {
          developer.log(
              'InventorySyncWorker: DELETEing /inventories/by-client/$clientUuid');
          await _api.delete('/inventories/by-client/$clientUuid');
          developer
              .log('InventorySyncWorker: Delete by client_uuid successful');
        } else {
          throw Exception('Missing server_id/client_uuid for delete');
        }
      }

      // Remove from queue on success
      await db.delete(
        'inventory_sync_queue',
        where: 'id = ?',
        whereArgs: [queueItem['id']],
      );

      developer.log(
          'InventorySyncWorker: Removed item ${queueItem['id']} from queue');
    } on ApiException catch (e) {
      developer.log(
          'InventorySyncWorker: API error - ${e.statusCode}: ${e.message}');

      if (e.statusCode == 409) {
        // Conflict
        await db.update(
          'inventory',
          {'conflict': 1},
          where: 'id = ?',
          whereArgs: [localId],
        );
      } else if (e.statusCode == 401) {
        developer.log('InventorySyncWorker: Unauthorized - stopping sync');
        rethrow; // Stop sync on auth error
      } else {
        rethrow;
      }
    }
  }

  bool _validatePayload(Map<String, dynamic> payload) {
    // Check required fields
    final requiredFields = ['item_name', 'category', 'quantity', 'unit'];

    for (final field in requiredFields) {
      if (!payload.containsKey(field) || payload[field] == null) {
        developer.log('InventorySyncWorker: Missing required field: $field');
        return false;
      }

      if (payload[field] is String &&
          (payload[field] as String).trim().isEmpty) {
        developer.log('InventorySyncWorker: Empty required field: $field');
        return false;
      }
    }

    return true;
  }

  Future<void> _markSynced(
    Database db,
    int localId,
    int serverId,
  ) async {
    await db.update(
      'inventory',
      {
        'is_synced': 1,
        'server_id': serverId,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }
}
