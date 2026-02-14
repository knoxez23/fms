import 'package:injectable/injectable.dart';
import '../domain/entities/feeding_schedule_entity.dart';
import '../domain/entities/feeding_log_entity.dart';
import '../domain/repositories/feeding_repository.dart';

@lazySingleton
class GetFeedingSchedules {
  final FeedingRepository repository;
  GetFeedingSchedules(this.repository);

  Future<List<FeedingScheduleEntity>> execute() async {
    return await repository.getSchedules();
  }
}

@lazySingleton
class GetFeedingLogs {
  final FeedingRepository repository;
  GetFeedingLogs(this.repository);

  Future<List<FeedingLogEntity>> execute() async {
    return await repository.getLogs();
  }
}

@lazySingleton
class AddFeedingSchedule {
  final FeedingRepository repository;
  AddFeedingSchedule(this.repository);

  Future<int> execute(FeedingScheduleEntity schedule) async {
    return await repository.addSchedule(schedule);
  }
}

@lazySingleton
class UpdateFeedingSchedule {
  final FeedingRepository repository;
  UpdateFeedingSchedule(this.repository);

  Future<int> execute(FeedingScheduleEntity schedule) async {
    return await repository.updateSchedule(schedule);
  }
}

@lazySingleton
class DeleteFeedingSchedule {
  final FeedingRepository repository;
  DeleteFeedingSchedule(this.repository);

  Future<int> execute(int id) async {
    return await repository.deleteSchedule(id);
  }
}

@lazySingleton
class AddFeedingLog {
  final FeedingRepository repository;
  AddFeedingLog(this.repository);

  Future<int> execute(FeedingLogEntity log) async {
    return await repository.addLog(log);
  }
}

@lazySingleton
class UpdateFeedingLog {
  final FeedingRepository repository;
  UpdateFeedingLog(this.repository);

  Future<int> execute(FeedingLogEntity log) async {
    return await repository.updateLog(log);
  }
}

@lazySingleton
class DeleteFeedingLog {
  final FeedingRepository repository;
  DeleteFeedingLog(this.repository);

  Future<int> execute(int id) async {
    return await repository.deleteLog(id);
  }
}
