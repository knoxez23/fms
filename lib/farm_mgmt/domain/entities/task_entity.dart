import '../value_objects/value_objects.dart';

class TaskEntity {
  final String? id;
  final TaskTitle title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? sourceEventType;
  final String? sourceEventId;

  TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.sourceEventType,
    this.sourceEventId,
  });

  bool get isOverdue {
    if (dueDate == null) return false;
    return !isCompleted && DateTime.now().isAfter(dueDate!);
  }
}
