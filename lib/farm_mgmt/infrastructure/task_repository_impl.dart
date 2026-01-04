import '../domain/repositories/task_repository.dart';
import '../domain/entities/entities.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl();

  @override
  Future<void> addTask(Task task) async {
    await LocalData.insertTask(task);
  }

  @override
  Future<void> deleteTask(int id) async {
    await LocalData.deleteTask(id);
  }

  @override
  Future<List<Task>> getTasks() async {
    return await LocalData.getTasks();
  }

  @override
  Future<void> updateTask(Task task) async {
    await LocalData.updateTask(task);
  }
}

