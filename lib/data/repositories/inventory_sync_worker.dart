import 'package:sqflite/sqflite.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/network/api_error.dart';

class InventorySyncWorker {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _api = ApiService();

  Future<void> sync() async {
    final Database db = await _dbHelper.database;

    final List<Map<String, dynamic>> queue = await db.query(
      'inventory_sync_queue',
      orderBy: 'created_at ASC',
    );

    for (final item in queue) {
      try {
        await _processItem(db, item);
      } catch (e) {
        // Stop sync on network/auth errors
        break;
      }
    }
  }

  Future<void> _processItem(
    Database db,
    Map<String, dynamic> queueItem,
  ) async {
    final String action = queueItem['action'];
    final Map<String, dynamic> payload =
        Map<String, dynamic>.from(queueItem['payload']);
    final int localId = queueItem['local_id'];
    final int? serverId = queueItem['server_id'];

    try {
      if (action == 'create') {
        final response = await _api.post(
          '/inventory',
          data: payload,
        );

        final int newServerId = response.data['id'];

        await _markSynced(db, localId, newServerId);
      }

      if (action == 'update' && serverId != null) {
        await _api.put(
          '/inventory/$serverId',
          data: payload,
        );

        await _markSynced(db, localId, serverId);
      }

      if (action == 'delete' && serverId != null) {
        await _api.delete('/inventory/$serverId');
      }

      await db.delete(
        'inventory_sync_queue',
        where: 'id = ?',
        whereArgs: [queueItem['id']],
      );
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        // Conflict
        await db.update(
          'inventory',
          {'conflict': 1},
          where: 'id = ?',
          whereArgs: [localId],
        );
      } else {
        rethrow;
      }
    }
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
        'conflict': 0,
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }
}
