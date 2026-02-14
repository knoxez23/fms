import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import '../domain/entities/feeding_schedule_entity.dart';
import '../domain/entities/feeding_log_entity.dart';
import '../domain/repositories/feeding_repository.dart';
import 'mappers/feeding_mapper.dart';

@LazySingleton(as: FeedingRepository)
class FeedingRepositoryImpl implements FeedingRepository {
  final SyncData _syncData;

  FeedingRepositoryImpl(this._syncData);

  @override
  Future<List<FeedingScheduleEntity>> getSchedules() async {
    final schedules = await _syncData.getFeedingSchedules();
    return schedules.map(FeedingMapper.scheduleToEntity).toList();
  }

  @override
  Future<List<FeedingLogEntity>> getLogs() async {
    final logs = await _syncData.getFeedingLogs();
    return logs.map(FeedingMapper.logToEntity).toList();
  }

  @override
  Future<int> addSchedule(FeedingScheduleEntity schedule) async {
    final model = FeedingMapper.scheduleToModel(schedule);
    return await _syncData.insertFeedingSchedule(model);
  }

  @override
  Future<int> updateSchedule(FeedingScheduleEntity schedule) async {
    final model = FeedingMapper.scheduleToModel(schedule);
    return await _syncData.updateFeedingSchedule(model);
  }

  @override
  Future<int> deleteSchedule(int id) async {
    return await _syncData.deleteFeedingSchedule(id);
  }

  @override
  Future<int> addLog(FeedingLogEntity log) async {
    final model = FeedingMapper.logToModel(log);
    return await _syncData.insertFeedingLog(model);
  }

  @override
  Future<int> updateLog(FeedingLogEntity log) async {
    final model = FeedingMapper.logToModel(log);
    return await _syncData.updateFeedingLog(model);
  }

  @override
  Future<int> deleteLog(int id) async {
    return await _syncData.deleteFeedingLog(id);
  }
}
