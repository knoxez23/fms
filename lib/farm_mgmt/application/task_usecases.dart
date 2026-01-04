// Use-cases for task feature
import '../domain/repositories/repositories.dart';
import '../domain/entities/entities.dart';

class GetTasks {
  final TaskRepository repository;
  GetTasks(this.repository);

  Future<List<Task>> execute() async => await repository.getTasks();
}

class AddTask {
  final TaskRepository repository;
  AddTask(this.repository);

  Future<void> execute(Task task) async => await repository.addTask(task);
}
