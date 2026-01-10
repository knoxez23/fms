import 'dart:convert';
import 'dart:developer' as developer;

import '../network/api_service.dart';
import '../services/connectivity_service.dart';
import 'local_data.dart';
import '../database/database_helper.dart';
import '../models/animal.dart';
import '../models/crop.dart';
import '../models/task.dart';
import '../models/feeding_schedule.dart';
import '../models/feeding_log.dart';

class SyncData {
  static final SyncData _instance = SyncData._internal();
  factory SyncData() => _instance;

  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();
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
          await LocalData.insertAnimal(animal);
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
        return await LocalData.insertAnimal(createdAnimal);
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
          await LocalData.insertCrop(crop);
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
        return await LocalData.insertCrop(createdCrop);
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

        for (var task in tasks) {
          await LocalData.insertTask(task);
        }

        return tasks;
      } catch (e, st) {
        developer.log('getTasks API failed: $e', error: e, stackTrace: st);
        return await LocalData.getTasks();
      }
    } else {
      return await LocalData.getTasks();
    }
  }

  Future<int> insertTask(Task task) async {
    if (await _isOnline()) {
      try {
        final response = await _apiService.post('/tasks', data: task.toMap());
        final createdTask = Task.fromMap(response.data);
        return await LocalData.insertTask(createdTask);
      } catch (e, st) {
        developer.log('insertTask API failed, storing locally: $e',
            error: e, stackTrace: st);
        return await LocalData.insertTask(task);
      }
    } else {
      return await LocalData.insertTask(task);
    }
  }

  Future<int> updateTask(Task task) async {
    if (await _isOnline()) {
      try {
        await _apiService.put('/tasks/${task.id}', data: task.toMap());
      } catch (e, st) {
        developer.log('updateTask API failed, updating local only: $e',
            error: e, stackTrace: st);
      }
    }
    return await LocalData.updateTask(task);
  }

  Future<int> deleteTask(int id) async {
    if (await _isOnline()) {
      try {
        await _apiService.delete('/tasks/$id');
      } catch (e, st) {
        developer.log('deleteTask API failed, deleting local only: $e',
            error: e, stackTrace: st);
      }
    }
    return await LocalData.deleteTask(id);
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
          await LocalData.insertFeedingSchedule(schedule);
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
        return await LocalData.insertFeedingSchedule(createdSchedule);
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
          await LocalData.insertFeedingLog(log);
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
        return await LocalData.insertFeedingLog(createdLog);
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

  // Farm summary
  Future<Map<String, dynamic>> getFarmSummary() async {
    return await LocalData.getFarmSummary();
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

  /// Queue an inventory action for background sync
  Future<void> queueInventoryAction({
    required int localId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final db = await _dbHelper.database;

      final queueItem = {
        'inventory_local_id': localId,
        'action': action,
        'payload': jsonEncode(payload),
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
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
    return await db.query(
      'inventory_sync_queue',
      orderBy: 'created_at ASC',
    );
  }

  /// Remove a sync action from queue
  Future<void> removeInventorySyncAction(int queueId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'inventory_sync_queue',
      where: 'id = ?',
      whereArgs: [queueId],
    );
  }

  /// Update retry count for a sync action
  Future<void> incrementRetryCount(int queueId, int currentCount) async {
    final db = await _dbHelper.database;
    await db.update(
      'inventory_sync_queue',
      {'retry_count': currentCount + 1},
      where: 'id = ?',
      whereArgs: [queueId],
    );
  }
}
