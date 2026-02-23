// Use-cases for task feature
import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';
import '../domain/entities/task_entity.dart';
import '../domain/entities/task_aggregate.dart';
import '../domain/events/farm_domain_events.dart';
import '../domain/repositories/repositories.dart';

@lazySingleton
class GetTasks {
  final TaskRepository repository;
  GetTasks(this.repository);

  Future<List<TaskEntity>> execute() async => await repository.getTasks();
}

@lazySingleton
class AddTask {
  final TaskRepository repository;
  AddTask(this.repository);

  Future<TaskEntity> execute(TaskEntity task) async {
    TaskAggregate(task);
    return await repository.addTask(task);
  }
}

@lazySingleton
class UpdateTask {
  final TaskRepository repository;
  final DomainEventBus _eventBus;
  UpdateTask(this.repository, this._eventBus);

  Future<TaskEntity> execute(TaskEntity task) async {
    TaskAggregate(task);
    final updated = await repository.updateTask(task);
    if (updated.isCompleted) {
      _eventBus.publish(
        TaskCompleted(
          taskId: updated.id,
          title: updated.title.value,
        ),
      );
    }
    return updated;
  }
}

@lazySingleton
class DeleteTask {
  final TaskRepository repository;
  DeleteTask(this.repository);

  Future<void> execute(String id) async => await repository.deleteTask(id);
}
