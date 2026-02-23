import '../entities/feeding_schedule_entity.dart';
import '../entities/feeding_log_entity.dart';

abstract class FeedingRepository {
  Future<List<FeedingScheduleEntity>> getSchedules();
  Future<List<FeedingLogEntity>> getLogs();
  Future<int> addSchedule(FeedingScheduleEntity schedule);
  Future<int> updateSchedule(FeedingScheduleEntity schedule);
  Future<int> deleteSchedule(int id);
  Future<int> addLog(FeedingLogEntity log);
  Future<int> updateLog(FeedingLogEntity log);
  Future<int> deleteLog(int id);
}
