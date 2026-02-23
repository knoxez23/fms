import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:pamoja_twalima/features/inventory/domain/repositories/inventory_repository.dart';
import 'local_data.dart';
import 'sync_data.dart';
import '../services/sale_service.dart';
import 'inventory_sync_worker.dart';
import '../../core/di/injection.dart';
import '../network/api_service.dart';
import '../models/task.dart';

class SyncWorker {
  static final SyncWorker _instance = SyncWorker._internal();
  factory SyncWorker() => _instance;

  Timer? _timer;
  bool _running = false;
  final ApiService _apiService = ApiService();

  SyncWorker._internal();

  void start({
    Duration interval = const Duration(minutes: 2),
    bool runImmediately = true,
  }) {
    if (_timer != null) return;
    _timer = Timer.periodic(interval, (_) => _runOnce());
    developer
        .log('SyncWorker started, interval: ${interval.inMinutes} minutes');
    if (runImmediately) {
      // Run cleanup and sync immediately once
      _runOnce();
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    developer.log('SyncWorker stopped');
  }

  Future<void> _runOnce() async {
    if (_running) return;
    _running = true;

    try {
      // First, cleanup invalid entries
      await _cleanupInvalidEntries();

      // Sync pending sales
      await _syncPendingSales();

      // Sync pending task deletes
      await _syncPendingTaskActions();
      await _syncPendingTaskDeletes();

      // Sync inventory items
      await _syncInventory();
    } catch (e, st) {
      developer.log('SyncWorker: unexpected error: $e',
          error: e, stackTrace: st);
    } finally {
      _running = false;
    }
  }

  /// Pull data from server to local database
  Future<void> syncFromServer() async {
    try {
      developer.log('📥 Syncing data from server...');

      final syncData = getIt<SyncData>();
      await _syncPendingTaskActions();
      await _syncPendingTaskDeletes();

      // Keep pull logic centralized in repositories/sync data.
      await getIt<InventoryRepository>().getItems();
      await syncData.getAnimals();
      await syncData.getCrops();
      await syncData.getTasks();
      await syncData.getFeedingSchedules();
      await syncData.getFeedingLogs();
      await syncData.getSales();

      developer.log('✅ Server sync completed');
    } catch (e, st) {
      developer.log('❌ Server sync failed: $e', error: e, stackTrace: st);
    }
  }

  Future<void> _syncPendingTaskDeletes() async {
    final pending = await LocalData.getPendingTaskDeletes();
    if (pending.isEmpty) return;

    for (final row in pending) {
      final queueId = row['id'] as int;
      final taskServerId = row['task_server_id'] as int?;
      final retryCount = row['retry_count'] as int? ?? 0;

      if (taskServerId == null) {
        await LocalData.deletePendingTaskDelete(queueId);
        continue;
      }

      try {
        await _apiService.delete('/tasks/$taskServerId');
        await LocalData.deletePendingTaskDelete(queueId);
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          await LocalData.deletePendingTaskDelete(queueId);
          continue;
        }

        final nextRetry = retryCount + 1;
        if (nextRetry >= 3) {
          await LocalData.deletePendingTaskDelete(queueId);
          continue;
        }

        await LocalData.updatePendingTaskDeleteRetryCount(queueId, nextRetry);
      } catch (e) {
        final nextRetry = retryCount + 1;
        if (nextRetry >= 3) {
          await LocalData.deletePendingTaskDelete(queueId);
          continue;
        }
        await LocalData.updatePendingTaskDeleteRetryCount(queueId, nextRetry);
      }
    }
  }

  Future<void> _syncPendingTaskActions() async {
    final pending = await LocalData.getPendingTaskActions();
    if (pending.isEmpty) return;

    for (final row in pending) {
      final queueId = row['id'] as int;
      final localId = row['task_local_id'] as int?;
      final action = row['action'] as String? ?? '';
      final payloadText = row['payload'] as String? ?? '';
      final retryCount = row['retry_count'] as int? ?? 0;

      if (localId == null || payloadText.isEmpty) {
        await LocalData.deletePendingTaskAction(queueId);
        continue;
      }

      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(payloadText) as Map<String, dynamic>;
      } catch (_) {
        await LocalData.deletePendingTaskAction(queueId);
        continue;
      }

      try {
        if (action == 'create') {
          final response = await _apiService.post('/tasks', data: payload);
          final created = Task.fromMap(
            Map<String, dynamic>.from(response.data as Map),
          ).copyWith(isSynced: true);

          if (created.id != null && created.id != localId) {
            await LocalData.deleteTask(localId);
          }
          await LocalData.upsertTask(created);
          await LocalData.deletePendingTaskActionsForLocalId(localId);
          continue;
        }

        if (action == 'update') {
          await _apiService.put('/tasks/$localId', data: payload);
          final updated = Task(
            id: localId,
            title: payload['title']?.toString() ?? '',
            description: payload['description']?.toString(),
            dueDate: payload['due_date']?.toString(),
            priority: payload['priority']?.toString(),
            status: payload['status']?.toString(),
            category: payload['category']?.toString(),
            assignedTo: payload['assigned_to']?.toString(),
            staffMemberId: _parseInt(payload['staff_member_id']),
            sourceEventType: payload['source_event_type']?.toString(),
            sourceEventId: payload['source_event_id']?.toString(),
            isSynced: true,
          );
          await LocalData.updateTask(updated);
          await LocalData.deletePendingTaskAction(queueId);
          continue;
        }

        await LocalData.deletePendingTaskAction(queueId);
      } on ApiException catch (e) {
        if (e.statusCode == 404 && action == 'update') {
          // Remote row missing, fallback to create with same payload.
          await LocalData.queueTaskAction(
            localId: localId,
            action: 'create',
            payload: payload,
          );
          await LocalData.deletePendingTaskAction(queueId);
          continue;
        }

        final nextRetry = retryCount + 1;
        if (nextRetry >= 3) {
          await LocalData.deletePendingTaskAction(queueId);
          continue;
        }
        await LocalData.updatePendingTaskActionRetryCount(queueId, nextRetry);
      } catch (_) {
        final nextRetry = retryCount + 1;
        if (nextRetry >= 3) {
          await LocalData.deletePendingTaskAction(queueId);
          continue;
        }
        await LocalData.updatePendingTaskActionRetryCount(queueId, nextRetry);
      }
    }
  }

  /// Sync pending inventory items to the server
  Future<void> _syncInventory() async {
    try {
      final worker = InventorySyncWorker();
      await worker.sync();
      developer.log('SyncWorker: inventory sync completed');
    } catch (e, st) {
      developer.log('SyncWorker: inventory sync failed: $e',
          error: e, stackTrace: st);
    }
  }

  /// Sync pending sales to the server
  Future<void> _syncPendingSales() async {
    final pending = await LocalData.getPendingSales();
    if (pending.isEmpty) {
      return;
    }

    developer.log('SyncWorker: found ${pending.length} pending sales to sync');

    for (final row in pending) {
      final id = row['id'] as int;
      final payloadText = row['payload'] as String? ?? '';

      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(payloadText) as Map<String, dynamic>;
      } catch (e) {
        developer
            .log('SyncWorker: invalid JSON for pending sale id=$id, deleting');
        await LocalData.deletePendingSale(id);
        continue;
      }

      // Validate product_name before attempting sync
      if (!_isValidSale(payload)) {
        developer.log(
            'SyncWorker: deleting invalid pending sale id=$id (validation failed)');
        await LocalData.deletePendingSale(id);
        continue;
      }

      // Transform payload to match Laravel expectations
      final transformedPayload = _transformPayloadForApi(payload);

      try {
        final result = await getIt<SaleService>().create(transformedPayload);
        developer.log(
            'SyncWorker: successfully synced pending sale id=$id, server returned: $result');

        if (result.containsKey('id')) {
          await _upsertLocalSaleFromSync(payload, result);
        }

        // On success, remove from pending queue
        await LocalData.deletePendingSale(id);

        developer.log('SyncWorker: completed sync for pending sale id=$id');
      } catch (e, st) {
        developer.log(
          'SyncWorker: failed to sync pending sale id=$id: $e',
          error: e,
          stackTrace: st,
        );
        // Don't delete; will retry later
      }
    }
  }

  /// Clean up invalid pending sales entries
  Future<void> _cleanupInvalidEntries() async {
    try {
      final pending = await LocalData.getPendingSales();
      int deletedCount = 0;

      for (final row in pending) {
        final id = row['id'] as int;
        final payloadText = row['payload'] as String? ?? '';

        if (payloadText.isEmpty) {
          await LocalData.deletePendingSale(id);
          deletedCount++;
          continue;
        }

        Map<String, dynamic> payload;
        try {
          payload = jsonDecode(payloadText) as Map<String, dynamic>;
        } catch (e) {
          developer.log('Cleanup: invalid JSON for id=$id, deleting');
          await LocalData.deletePendingSale(id);
          deletedCount++;
          continue;
        }

        if (!_isValidSale(payload)) {
          developer.log('Cleanup: invalid sale data for id=$id, deleting');
          await LocalData.deletePendingSale(id);
          deletedCount++;
        }
      }

      if (deletedCount > 0) {
        developer
            .log('SyncWorker cleanup: removed $deletedCount invalid entries');
      }
    } catch (e, st) {
      developer.log('Cleanup failed: $e', error: e, stackTrace: st);
    }
  }

  /// Validate sale data
  bool _isValidSale(Map<String, dynamic> payload) {
    final productName = payload['product_name'];
    if (productName == null ||
        productName is! String ||
        productName.trim().isEmpty) {
      return false;
    }

    // Add more validation as needed
    final quantity = _parseNum(payload['quantity']);
    if (quantity == null || quantity <= 0) {
      return false;
    }

    return true;
  }

  Future<void> _upsertLocalSaleFromSync(
    Map<String, dynamic> payload,
    Map<String, dynamic> serverResult,
  ) async {
    final merged = {
      ...payload,
      ...serverResult,
      'server_id': serverResult['id'],
      'sale_date': serverResult['sale_date'] ?? payload['sale_date'],
      'customer_name':
          serverResult['customer_name'] ?? payload['customer_name'],
      'customer_id': serverResult['customer_id'] ?? payload['customer_id'],
    };

    final serverId = _parseInt(serverResult['id']);
    int? localId = _parseInt(payload['local_id']);
    if (localId == null && serverId != null) {
      localId = await LocalData.findSaleIdByServerId(serverId);
    }
    localId ??= await LocalData.findSaleIdByPayload(payload);

    if (localId != null) {
      await LocalData.updateSale(localId, merged);
      return;
    }

    await LocalData.upsertSaleFromServer(merged);
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _parseNum(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Transform Flutter payload to match Laravel API expectations
  Map<String, dynamic> _transformPayloadForApi(Map<String, dynamic> payload) {
    return {
      'product_name': payload['product_name'],
      'quantity': payload['quantity'],
      'unit': payload['unit'],
      'price': payload['price'],
      'total_amount': payload['total_amount'],
      'customer_name': payload['customer_name'] ?? payload['customer'],
      'customer_id': payload['customer_id'],
      'sale_date': payload['sale_date'] ?? payload['date'],
      'payment_status': payload['payment_status'],
      'notes': payload['notes'] ?? '',
      // user_id will be added by Laravel controller from auth()->id()
    };
  }
}
