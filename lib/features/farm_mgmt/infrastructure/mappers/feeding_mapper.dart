import '../../../../data/models/feeding_schedule.dart';
import '../../../../data/models/feeding_log.dart';
import '../../domain/entities/feeding_schedule_entity.dart';
import '../../domain/entities/feeding_log_entity.dart';

class FeedingMapper {
  static FeedingScheduleEntity scheduleToEntity(FeedingSchedule model) {
    return FeedingScheduleEntity(
      id: model.id,
      animalId: model.animalId,
      inventoryId: model.inventoryId,
      feedType: model.feedType,
      quantity: model.quantity,
      unit: model.unit,
      timeOfDay: model.timeOfDay,
      frequency: model.frequency,
      startDate:
          model.startDate != null ? DateTime.tryParse(model.startDate!) : null,
      endDate: model.endDate != null ? DateTime.tryParse(model.endDate!) : null,
      notes: model.notes,
      completed: model.completed,
    );
  }

  static FeedingSchedule scheduleToModel(FeedingScheduleEntity entity) {
    return FeedingSchedule(
      id: entity.id,
      animalId: entity.animalId,
      inventoryId: entity.inventoryId,
      feedType: entity.feedType,
      quantity: entity.quantity,
      unit: entity.unit,
      timeOfDay: entity.timeOfDay,
      frequency: entity.frequency,
      startDate: entity.startDate?.toIso8601String(),
      endDate: entity.endDate?.toIso8601String(),
      notes: entity.notes,
      completed: entity.completed,
    );
  }

  static FeedingLogEntity logToEntity(FeedingLog model) {
    return FeedingLogEntity(
      id: model.id,
      animalId: model.animalId,
      scheduleId: model.scheduleId,
      inventoryId: model.inventoryId,
      feedType: model.feedType,
      quantity: model.quantity,
      unit: model.unit,
      fedAt: DateTime.parse(model.fedAt),
      fedBy: model.fedBy,
      notes: model.notes,
    );
  }

  static FeedingLog logToModel(FeedingLogEntity entity) {
    return FeedingLog(
      id: entity.id,
      animalId: entity.animalId,
      scheduleId: entity.scheduleId,
      inventoryId: entity.inventoryId,
      feedType: entity.feedType,
      quantity: entity.quantity,
      unit: entity.unit,
      fedAt: entity.fedAt.toIso8601String(),
      fedBy: entity.fedBy,
      notes: entity.notes,
    );
  }
}
