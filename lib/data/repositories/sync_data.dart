import 'dart:convert';
import 'dart:developer' as developer;
import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/core/services/local_session_service.dart';
import 'package:uuid/uuid.dart';

import '../network/api_service.dart';
import '../services/connectivity_service.dart';
import 'local_data.dart';
import '../database/database_helper.dart';
import '../models/animal.dart';
import '../models/crop.dart';
import '../models/task.dart';
import '../models/feeding_schedule.dart';
import '../models/feeding_log.dart';
import '../models/animal_health_record.dart';
import '../../features/home/domain/entities/dashboard_data.dart';

class TaskResolutionRule {
  final String? sourceEventType;
  final String? sourceEventId;
  final List<String> titleContains;

  const TaskResolutionRule({
    this.sourceEventType,
    this.sourceEventId,
    this.titleContains = const [],
  });
}

@lazySingleton
class SyncData {
  static final SyncData _instance = SyncData._internal();
  factory SyncData() => _instance;

  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const Uuid _uuid = Uuid();
  // No instance needed, using static methods

  SyncData._internal();

  Future<bool> _isOnline() async {
    return await _connectivityService.isOnline();
  }

  // Animal operations
  Future<List<Animal>> getAnimals() async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.get('/animals');
        final List<dynamic> data = response.data;
        final animals = data.map((json) => Animal.fromMap(json)).toList();

        // Store locally for offline access
        for (var animal in animals) {
          await LocalData.upsertAnimal(animal);
        }

        return animals;
      } catch (e, st) {
        developer.log('getAnimals API failed: $e', error: e, stackTrace: st);
        // Fallback to local
        return await LocalData.getAnimals();
      }
    } else {
      return await LocalData.getAnimals();
    }
  }

  Future<int> insertAnimal(Animal animal) async {
    if (await _isOnline()) {
      try {
        final response =
            await _apiService.post('/animals', data: animal.toMap());
        final createdAnimal = Animal.fromMap(response.data);
        return await LocalData.upsertAnimal(createdAnimal);
      } catch (e, st) {
        developer.log('insertAnimal API failed, storing locally: $e',
            error: e, stackTrace: st);
        // Store locally and mark for sync later
        return await LocalData.insertAnimal(animal);
      }
    } else {
      return await LocalData.insertAnimal(animal);
    }
  }

  Future<int> updateAnimal(Animal animal) async {
    if (await _isOnline()) {
      try {
        await _apiService.put('/animals/${animal.id}', data: animal.toMap());
      } catch (e, st) {
        developer.log('updateAnimal API failed, updating local only: $e',
            error: e, stackTrace: st);
        // Continue to update local
      }
    }
    return await LocalData.updateAnimal(animal);
  }

  Future<int> deleteAnimal(int id) async {
    if (await _isOnline()) {
      try {
        await _apiService.delete('/animals/$id');
      } catch (e, st) {
        developer.log('deleteAnimal API failed, deleting local only: $e',
            error: e, stackTrace: st);
        // Continue to delete local
      }
    }
    return await LocalData.deleteAnimal(id);
  }

  // Crop operations
  Future<List<Crop>> getCrops() async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.get('/crops');
        final List<dynamic> data = response.data;
        final crops = data.map((json) => Crop.fromMap(json)).toList();

        for (var crop in crops) {
          await LocalData.upsertCrop(crop);
        }

        return crops;
      } catch (e, st) {
        developer.log('getCrops API failed: $e', error: e, stackTrace: st);
        return await LocalData.getCrops();
      }
    } else {
      return await LocalData.getCrops();
    }
  }

  Future<int> insertCrop(Crop crop) async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.post('/crops', data: crop.toMap());
        final createdCrop = Crop.fromMap(response.data);
        return await LocalData.upsertCrop(createdCrop);
      } catch (e, st) {
        developer.log('insertCrop API failed, storing locally: $e',
            error: e, stackTrace: st);
        return await LocalData.insertCrop(crop);
      }
    } else {
      return await LocalData.insertCrop(crop);
    }
  }

  Future<int> updateCrop(Crop crop) async {
    if (await _isOnline()) {
      try {
        await _apiService.put('/crops/${crop.id}', data: crop.toMap());
      } catch (e, st) {
        developer.log('updateCrop API failed, updating local only: $e',
            error: e, stackTrace: st);
      }
    }
    return await LocalData.updateCrop(crop);
  }

  Future<int> deleteCrop(int id) async {
    if (await _isOnline()) {
      try {
        await _apiService.delete('/crops/$id');
      } catch (e, st) {
        developer.log('deleteCrop API failed, deleting local only: $e',
            error: e, stackTrace: st);
      }
    }
    return await LocalData.deleteCrop(id);
  }

  // Task operations
  Future<List<Task>> getTasks() async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.get('/tasks');
        final List<dynamic> data = response.data;
        final tasks = data.map((json) => Task.fromMap(json)).toList();
        final pendingDeleteIds =
            await LocalData.getPendingTaskDeleteServerIds();
        final filtered =
            tasks.where((task) => !pendingDeleteIds.contains(task.id)).toList();

        for (var task in filtered) {
          if (task.id != null && await _isTaskLocallyUnsynced(task.id!)) {
            // Preserve local unsynced edits and let outbound sync win.
            continue;
          }
          await LocalData.upsertTask(task);
        }
        final localTasks = await LocalData.getTasks();
        final serverIds = filtered
            .where((task) => task.id != null)
            .map((task) => task.id!)
            .toSet();
        final serverClientUuids = filtered
            .map((task) => task.clientUuid)
            .whereType<String>()
            .where((uuid) => uuid.isNotEmpty)
            .toSet();
        final merged = <Task>[...filtered];

        // Keep local-only unsynced edits/creates visible in UI while online.
        for (final local in localTasks) {
          final isLocalOnly =
              local.id != null && !serverIds.contains(local.id!);
          final matchesServerClientUuid = local.clientUuid != null &&
              serverClientUuids.contains(local.clientUuid);
          if (local.isSynced == false || isLocalOnly) {
            final exists = merged.any((task) => task.id == local.id);
            if (!exists && !matchesServerClientUuid) merged.add(local);
          }
        }

        return merged;
      } catch (e, st) {
        developer.log('getTasks API failed: $e', error: e, stackTrace: st);
        return await LocalData.getTasks();
      }
    } else {
      return await LocalData.getTasks();
    }
  }

  Future<int> insertTask(Task task) async {
    final normalizedTask = _applyTaskApprovalDefaults(task);
    final taskWithClientUuid =
        normalizedTask.clientUuid == null || normalizedTask.clientUuid!.isEmpty
            ? normalizedTask.copyWith(clientUuid: _uuid.v4())
            : normalizedTask;
    final payload = _taskPayload(taskWithClientUuid);
    if (await _isOnline()) {
      try {
        final response = await _apiService.post('/tasks', data: payload);
        final createdTask =
            Task.fromMap(response.data).copyWith(isSynced: true);
        return await LocalData.upsertTask(createdTask);
      } catch (e, st) {
        developer.log('insertTask API failed, storing locally: $e',
            error: e, stackTrace: st);
        final localId = await LocalData.insertTask(
            taskWithClientUuid.copyWith(isSynced: false, id: null));
        await LocalData.queueTaskAction(
          localId: localId,
          action: 'create',
          payload: payload,
        );
        return localId;
      }
    } else {
      final localId = await LocalData.insertTask(
          taskWithClientUuid.copyWith(isSynced: false, id: null));
      await LocalData.queueTaskAction(
        localId: localId,
        action: 'create',
        payload: payload,
      );
      return localId;
    }
  }

  Future<int> updateTask(Task task) async {
    final normalizedTask = _applyTaskApprovalDefaults(task);
    if (await _isOnline()) {
      try {
        final response =
            await _apiService.put('/tasks/${normalizedTask.id}',
                data: _taskPayload(normalizedTask));
        final updatedTask =
            Task.fromMap(response.data).copyWith(isSynced: true);
        return await LocalData.updateTask(updatedTask);
      } catch (e, st) {
        developer.log('updateTask API failed, updating local only: $e',
            error: e, stackTrace: st);
        final updated =
            await LocalData.updateTask(normalizedTask.copyWith(isSynced: false));
        final localId = normalizedTask.id;
        if (localId != null) {
          await LocalData.queueTaskAction(
            localId: localId,
            action: 'update',
            payload: _taskPayload(normalizedTask),
          );
        }
        return updated;
      }
    } else {
      final updated =
          await LocalData.updateTask(normalizedTask.copyWith(isSynced: false));
      final localId = normalizedTask.id;
      if (localId != null) {
        await LocalData.queueTaskAction(
          localId: localId,
          action: 'update',
          payload: _taskPayload(normalizedTask),
        );
      }
      return updated;
    }
  }

  Future<int> completeTasksWhere({
    String? sourceEventType,
    String? sourceEventId,
    List<String> titleContains = const [],
  }) async {
    final tasks = await LocalData.getTasks();
    var completed = 0;

    for (final task in tasks) {
      final status = (task.status ?? 'pending').toLowerCase();
      if (status == 'completed') continue;

      final matchesSourceType = sourceEventType == null ||
          (task.sourceEventType ?? '').toLowerCase() ==
              sourceEventType.toLowerCase();
      final matchesSourceId =
          sourceEventId == null || (task.sourceEventId ?? '') == sourceEventId;
      final lowerTitle = task.title.toLowerCase();
      final matchesTitle = titleContains.isEmpty ||
          titleContains.any((item) => lowerTitle.contains(item.toLowerCase()));

      if (!matchesSourceType || !matchesSourceId || !matchesTitle) continue;

      await updateTask(task.copyWith(status: 'completed'));
      completed++;
    }

    return completed;
  }

  Future<int> completeTaskRules(Iterable<TaskResolutionRule> rules) async {
    var completed = 0;
    for (final rule in rules) {
      completed += await completeTasksWhere(
        sourceEventType: rule.sourceEventType,
        sourceEventId: rule.sourceEventId,
        titleContains: rule.titleContains,
      );
    }
    return completed;
  }

  Future<int> deleteTask(int id) async {
    final isSyncedTask = await LocalData.isTaskSynced(id);
    await LocalData.deletePendingTaskActionsForLocalId(id);
    if (!isSyncedTask) {
      return await LocalData.deleteTask(id);
    }

    if (await _isOnline() && isSyncedTask) {
      try {
        await _apiService.delete('/tasks/$id');
        await LocalData.deletePendingTaskDeleteByServerId(id);
      } catch (e, st) {
        developer.log('deleteTask API failed, deleting local only: $e',
            error: e, stackTrace: st);
        await LocalData.queueTaskDelete(id);
      }
    } else if (isSyncedTask) {
      await LocalData.queueTaskDelete(id);
    }
    return await LocalData.deleteTask(id);
  }

  Future<bool> _isTaskLocallyUnsynced(int id) async {
    return LocalData.isTaskUnsynced(id);
  }

  Map<String, dynamic> _taskPayload(Task task) {
    return {
      'client_uuid': task.clientUuid,
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate,
      'priority': task.priority,
      'status': task.status ?? 'pending',
      'category': task.category,
      'assigned_to': task.assignedTo,
      'staff_member_id': task.staffMemberId,
      'source_event_type': task.sourceEventType,
      'source_event_id': task.sourceEventId,
      'approval_required': task.approvalRequired,
      'approval_status': task.approvalStatus,
      'approved_by': task.approvedBy,
      'approved_at': task.approvedAt,
    }..removeWhere((key, value) => value == null);
  }

  Task _applyTaskApprovalDefaults(Task task) {
    if (task.approvalRequired != null || task.approvalStatus != null) {
      return task;
    }

    final category = (task.category ?? '').toLowerCase();
    final sourceType = (task.sourceEventType ?? '').toLowerCase();
    final title = task.title.toLowerCase();
    final description = (task.description ?? '').toLowerCase();
    final sensitiveTitle = [
      'approve',
      'buyer terms',
      'repair',
      'payment',
      'stock',
      'market',
      'sale or storage',
      'sale',
      'transport',
    ].any((needle) => title.contains(needle) || description.contains(needle));
    final sensitiveCategory = category == 'inventory' ||
        category == 'maintenance' ||
        category == 'administrative';
    final sensitiveSource = sourceType == 'harvest' ||
        sourceType == 'inventory' ||
        sourceType == 'marketplace' ||
        sourceType == 'sale';

    final requiresApproval =
        sensitiveTitle || sensitiveCategory || sensitiveSource;

    if (!requiresApproval) {
      return task.copyWith(
        approvalRequired: false,
        approvalStatus: 'not_required',
      );
    }

    return task.copyWith(
      approvalRequired: true,
      approvalStatus: 'pending',
    );
  }

  // Feeding Schedule operations
  Future<List<FeedingSchedule>> getFeedingSchedules() async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.get('/feeding-schedules');
        final List<dynamic> data = response.data;
        final schedules =
            data.map((json) => FeedingSchedule.fromMap(json)).toList();

        for (var schedule in schedules) {
          await LocalData.upsertFeedingSchedule(schedule);
        }

        return schedules;
      } catch (e, st) {
        developer.log('getFeedingSchedules API failed: $e',
            error: e, stackTrace: st);
        return await LocalData.getFeedingSchedules();
      }
    } else {
      return await LocalData.getFeedingSchedules();
    }
  }

  Future<int> insertFeedingSchedule(FeedingSchedule schedule) async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.post('/feeding-schedules',
            data: schedule.toMap());
        final createdSchedule = FeedingSchedule.fromMap(response.data);
        return await LocalData.upsertFeedingSchedule(createdSchedule);
      } catch (e, st) {
        developer.log('insertFeedingSchedule API failed, storing locally: $e',
            error: e, stackTrace: st);
        return await LocalData.insertFeedingSchedule(schedule);
      }
    } else {
      return await LocalData.insertFeedingSchedule(schedule);
    }
  }

  Future<int> updateFeedingSchedule(FeedingSchedule schedule) async {
    if (await _isOnline()) {
      try {
        await _apiService.put('/feeding-schedules/${schedule.id}',
            data: schedule.toMap());
      } catch (e, st) {
        developer.log(
            'updateFeedingSchedule API failed, updating local only: $e',
            error: e,
            stackTrace: st);
      }
    }
    return await LocalData.updateFeedingSchedule(schedule);
  }

  Future<int> deleteFeedingSchedule(int id) async {
    if (await _isOnline()) {
      try {
        await _apiService.delete('/feeding-schedules/$id');
      } catch (e, st) {
        developer.log(
            'deleteFeedingSchedule API failed, deleting local only: $e',
            error: e,
            stackTrace: st);
      }
    }
    return await LocalData.deleteFeedingSchedule(id);
  }

  // Feeding Log operations
  Future<List<FeedingLog>> getFeedingLogs() async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.get('/feeding-logs');
        final List<dynamic> data = response.data;
        final logs = data.map((json) => FeedingLog.fromMap(json)).toList();

        for (var log in logs) {
          await LocalData.upsertFeedingLog(log);
        }

        return logs;
      } catch (e, st) {
        developer.log('getFeedingLogs API failed: $e',
            error: e, stackTrace: st);
        return await LocalData.getFeedingLogs();
      }
    } else {
      return await LocalData.getFeedingLogs();
    }
  }

  Future<int> insertFeedingLog(FeedingLog log) async {
    if (await _isOnline()) {
      try {
        final response =
            await _apiService.post('/feeding-logs', data: log.toMap());
        final createdLog = FeedingLog.fromMap(response.data);
        return await LocalData.upsertFeedingLog(createdLog);
      } catch (e, st) {
        developer.log('insertFeedingLog API failed, storing locally: $e',
            error: e, stackTrace: st);
        return await LocalData.insertFeedingLog(log);
      }
    } else {
      return await LocalData.insertFeedingLog(log);
    }
  }

  Future<int> updateFeedingLog(FeedingLog log) async {
    if (await _isOnline()) {
      try {
        await _apiService.put('/feeding-logs/${log.id}', data: log.toMap());
      } catch (e, st) {
        developer.log('updateFeedingLog API failed, updating local only: $e',
            error: e, stackTrace: st);
      }
    }
    return await LocalData.updateFeedingLog(log);
  }

  Future<int> deleteFeedingLog(int id) async {
    if (await _isOnline()) {
      try {
        await _apiService.delete('/feeding-logs/$id');
      } catch (e, st) {
        developer.log('deleteFeedingLog API failed, deleting local only: $e',
            error: e, stackTrace: st);
      }
    }
    return await LocalData.deleteFeedingLog(id);
  }

  // Animal Health Record operations
  Future<List<AnimalHealthRecord>> getAnimalHealthRecords() async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.get('/animal-health-records');
        final List<dynamic> data = response.data;
        final records =
            data.map((json) => AnimalHealthRecord.fromMap(json)).toList();

        for (final record in records) {
          await LocalData.upsertAnimalHealthRecord(record);
        }

        return records;
      } catch (e, st) {
        developer.log('getAnimalHealthRecords API failed: $e',
            error: e, stackTrace: st);
        return await LocalData.getAnimalHealthRecords();
      }
    } else {
      return await LocalData.getAnimalHealthRecords();
    }
  }

  Future<int> insertAnimalHealthRecord(AnimalHealthRecord record) async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.post(
          '/animal-health-records',
          data: record.toMap()..remove('id'),
        );
        final created = AnimalHealthRecord.fromMap(response.data);
        return await LocalData.upsertAnimalHealthRecord(created);
      } catch (e, st) {
        developer.log('insertAnimalHealthRecord API failed: $e',
            error: e, stackTrace: st);
        return await LocalData.insertAnimalHealthRecord(record);
      }
    } else {
      return await LocalData.insertAnimalHealthRecord(record);
    }
  }

  Future<int> updateAnimalHealthRecord(AnimalHealthRecord record) async {
    if (await _isOnline()) {
      try {
        await _apiService.put(
          '/animal-health-records/${record.id}',
          data: record.toMap()..remove('id'),
        );
      } catch (e, st) {
        developer.log('updateAnimalHealthRecord API failed: $e',
            error: e, stackTrace: st);
      }
    }
    return await LocalData.updateAnimalHealthRecord(record);
  }

  Future<int> deleteAnimalHealthRecord(int id) async {
    if (await _isOnline()) {
      try {
        await _apiService.delete('/animal-health-records/$id');
      } catch (e, st) {
        developer.log('deleteAnimalHealthRecord API failed: $e',
            error: e, stackTrace: st);
      }
    }
    return await LocalData.deleteAnimalHealthRecord(id);
  }

  // Farm summary
  Future<Map<String, dynamic>> getFarmSummary() async {
    final summary = await LocalData.getFarmSummary();
    try {
      final tasks = await getTasks();
      summary['pendingTasks'] = tasks.where((task) {
        final status = (task.status ?? '').toLowerCase();
        return status != 'completed';
      }).length;
    } catch (_) {
      // Keep local summary fallback when task fetch fails.
    }
    return summary;
  }

  Future<List<OperationalInsight>> getOperationalInsights() async {
    return LocalData.getOperationalInsights();
  }

  // Sales operations
  Future<List<Map<String, dynamic>>> getSales() async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.get('/sales');
        final List<dynamic> data = response.data;
        final rows =
            data.map((json) => Map<String, dynamic>.from(json as Map)).toList();

        for (final row in rows) {
          await LocalData.upsertSaleFromServer(row);
        }

        return rows;
      } catch (e, st) {
        developer.log('getSales API failed: $e', error: e, stackTrace: st);
        return await LocalData.getSales();
      }
    } else {
      return await LocalData.getSales();
    }
  }

  // Market prices (still mock)
  Future<List<Map<String, String>>> getMarketPrices() async {
    return await LocalData.getMarketPrices();
  }
}

class SyncDataRepository {
  static final SyncDataRepository _instance = SyncDataRepository._internal();
  factory SyncDataRepository() => _instance;
  SyncDataRepository._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LocalSessionService _localSessionService = LocalSessionService();

  static const Duration _inventoryDeleteTombstoneTtl = Duration(days: 30);

  /// Queue an inventory action for background sync
  Future<void> queueInventoryAction({
    required int localId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final db = await _dbHelper.database;
      final activeUserId = await _localSessionService.getActiveUserId();
      final encodedPayload = jsonEncode(payload);
      final existing = await db.query(
        'inventory_sync_queue',
        where: activeUserId == null
            ? 'inventory_local_id = ?'
            : 'inventory_local_id = ? AND user_id = ?',
        whereArgs: activeUserId == null ? [localId] : [localId, activeUserId],
        orderBy: 'created_at DESC',
      );

      if (action == 'delete') {
        // Delete supersedes any pending create/update for the same local row.
        await db.delete(
          'inventory_sync_queue',
          where: activeUserId == null
              ? 'inventory_local_id = ?'
              : 'inventory_local_id = ? AND user_id = ?',
          whereArgs: activeUserId == null ? [localId] : [localId, activeUserId],
        );
      } else if (action == 'update') {
        final createEntry = existing
            .where((row) => row['action'] == 'create')
            .cast<Map<String, dynamic>>()
            .toList();
        if (createEntry.isNotEmpty) {
          // Collapse create+update into a single create with latest payload.
          final createId = createEntry.first['id'];
          await db.update(
            'inventory_sync_queue',
            {
              'payload': encodedPayload,
              'created_at': DateTime.now().toIso8601String(),
              'retry_count': 0,
            },
            where: 'id = ?',
            whereArgs: [createId],
          );

          await db.delete(
            'inventory_sync_queue',
            where: activeUserId == null
                ? 'inventory_local_id = ? AND action = ? AND id != ?'
                : 'inventory_local_id = ? AND action = ? AND id != ? AND user_id = ?',
            whereArgs: activeUserId == null
                ? [localId, 'update', createId]
                : [localId, 'update', createId, activeUserId],
          );

          developer.log(
              'Coalesced inventory update into pending create for local_id=$localId');
          return;
        }

        final latestUpdate = existing.firstWhere(
          (row) => row['action'] == 'update',
          orElse: () => const <String, dynamic>{},
        );
        if (latestUpdate.isNotEmpty) {
          await db.update(
            'inventory_sync_queue',
            {
              'payload': encodedPayload,
              'created_at': DateTime.now().toIso8601String(),
              'retry_count': 0,
            },
            where: 'id = ?',
            whereArgs: [latestUpdate['id']],
          );
          developer
              .log('Replaced pending inventory update for local_id=$localId');
          return;
        }
      } else if (action == 'create') {
        final latestCreate = existing.firstWhere(
          (row) => row['action'] == 'create',
          orElse: () => const <String, dynamic>{},
        );
        if (latestCreate.isNotEmpty) {
          await db.update(
            'inventory_sync_queue',
            {
              'payload': encodedPayload,
              'created_at': DateTime.now().toIso8601String(),
              'retry_count': 0,
            },
            where: 'id = ?',
            whereArgs: [latestCreate['id']],
          );
          developer
              .log('Replaced pending inventory create for local_id=$localId');
          return;
        }
      }

      final queueItem = {
        'inventory_local_id': localId,
        'action': action,
        'payload': encodedPayload,
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
        'user_id': activeUserId,
      };

      await db.insert('inventory_sync_queue', queueItem);

      developer.log('Queued inventory $action for local_id=$localId');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to queue inventory action: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get all pending inventory sync actions
  Future<List<Map<String, dynamic>>> getPendingInventoryActions() async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    return await db.query(
      'inventory_sync_queue',
      where: activeUserId == null ? null : 'user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
      orderBy: 'created_at ASC',
    );
  }

  /// Remove a sync action from queue
  Future<void> removeInventorySyncAction(int queueId) async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    await db.delete(
      'inventory_sync_queue',
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [queueId] : [queueId, activeUserId],
    );
  }

  /// Remove all sync actions for a local inventory item
  Future<void> removeInventoryActionsForLocalId(int localId) async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    await db.delete(
      'inventory_sync_queue',
      where: activeUserId == null
          ? 'inventory_local_id = ?'
          : 'inventory_local_id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [localId] : [localId, activeUserId],
    );
  }

  /// Update retry count for a sync action
  Future<void> incrementRetryCount(int queueId, int currentCount) async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    await db.update(
      'inventory_sync_queue',
      {'retry_count': currentCount + 1},
      where: activeUserId == null ? 'id = ?' : 'id = ? AND user_id = ?',
      whereArgs: activeUserId == null ? [queueId] : [queueId, activeUserId],
    );
  }

  Future<void> addInventoryDeleteTombstone({
    required int localId,
    int? serverId,
    String? clientUuid,
  }) async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    final now = DateTime.now();
    final expiresAt = now.add(_inventoryDeleteTombstoneTtl).toIso8601String();
    final normalizedUuid =
        (clientUuid != null && clientUuid.isNotEmpty) ? clientUuid : null;

    // Keep one tombstone per remote identity to avoid duplicate rows.
    if (serverId != null) {
      await db.delete(
        'inventory_delete_tombstones',
        where: activeUserId == null
            ? 'server_id = ?'
            : 'server_id = ? AND user_id = ?',
        whereArgs: activeUserId == null ? [serverId] : [serverId, activeUserId],
      );
    } else if (normalizedUuid != null) {
      await db.delete(
        'inventory_delete_tombstones',
        where: activeUserId == null
            ? 'client_uuid = ?'
            : 'client_uuid = ? AND user_id = ?',
        whereArgs: activeUserId == null
            ? [normalizedUuid]
            : [normalizedUuid, activeUserId],
      );
    }

    await db.insert('inventory_delete_tombstones', {
      'inventory_local_id': localId,
      'server_id': serverId,
      'client_uuid': normalizedUuid,
      'deleted_at': now.toIso8601String(),
      'expires_at': expiresAt,
      'user_id': activeUserId,
    });
  }

  Future<void> purgeExpiredInventoryDeleteTombstones() async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    await db.delete(
      'inventory_delete_tombstones',
      where: activeUserId == null
          ? 'expires_at <= ?'
          : 'expires_at <= ? AND user_id = ?',
      whereArgs: activeUserId == null
          ? [DateTime.now().toIso8601String()]
          : [DateTime.now().toIso8601String(), activeUserId],
    );
  }

  Future<Set<int>> getInventoryDeleteTombstoneServerIds() async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    final rows = await db.query(
      'inventory_delete_tombstones',
      columns: ['server_id'],
      where: activeUserId == null
          ? 'server_id IS NOT NULL'
          : 'server_id IS NOT NULL AND user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );
    return rows.map((row) => row['server_id']).whereType<int>().toSet();
  }

  Future<Set<String>> getInventoryDeleteTombstoneClientUuids() async {
    final db = await _dbHelper.database;
    final activeUserId = await _localSessionService.getActiveUserId();
    final rows = await db.query(
      'inventory_delete_tombstones',
      columns: ['client_uuid'],
      where: activeUserId == null
          ? 'client_uuid IS NOT NULL'
          : 'client_uuid IS NOT NULL AND user_id = ?',
      whereArgs: activeUserId == null ? null : [activeUserId],
    );
    return rows
        .map((row) => row['client_uuid'])
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();
  }
}
