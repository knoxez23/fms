import 'task_entity.dart';

class TaskAggregate {
  final TaskEntity task;

  TaskAggregate(this.task) {
    _validate(task);
  }

  void _validate(TaskEntity value) {
    if (value.title.value.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty');
    }
    if (value.dueDate != null && value.dueDate!.year < 2000) {
      throw ArgumentError('Task due date is invalid');
    }
  }

  TaskEntity complete() {
    return TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: true,
      sourceEventType: task.sourceEventType,
      sourceEventId: task.sourceEventId,
    );
  }
}
