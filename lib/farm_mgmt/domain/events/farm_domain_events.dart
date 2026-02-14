import 'package:pamoja_twalima/core/domain/events/domain_event.dart';

class AnimalBred extends DomainEvent {
  final String damAnimalId;
  final String? sireAnimalId;
  final DateTime expectedBirthDate;

  AnimalBred({
    required this.damAnimalId,
    required this.sireAnimalId,
    required this.expectedBirthDate,
  });
}

class CropHarvested extends DomainEvent {
  final String? cropId;
  final String cropName;
  final DateTime harvestedAt;

  CropHarvested({
    required this.cropId,
    required this.cropName,
    DateTime? harvestedAt,
  }) : harvestedAt = harvestedAt ?? DateTime.now();
}

class TaskCompleted extends DomainEvent {
  final String? taskId;
  final String title;

  TaskCompleted({
    required this.taskId,
    required this.title,
  });
}
