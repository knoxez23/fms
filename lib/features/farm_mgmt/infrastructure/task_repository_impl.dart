import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/models/task.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/entities/task_entity.dart';
import '../domain/value_objects/value_objects.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final SyncData _syncData;

  TaskRepositoryImpl(this._syncData);

  @override
  Future<TaskEntity> addTask(TaskEntity task) async {
    final model = _mapToModel(task);
    final id = await _syncData.insertTask(model);
    return _withId(task, id.toString());
  }

  @override
  Future<void> deleteTask(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    await _syncData.deleteTask(parsed);
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    final rows = await _syncData.getTasks();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    final model = _mapToModel(task);
    await _syncData.updateTask(model);
    return task;
  }

  TaskEntity _mapToEntity(Task model) {
    return TaskEntity(
      id: model.id?.toString(),
      title: TaskTitle(model.title),
      description: model.description,
      dueDate: model.dueDate != null ? DateTime.tryParse(model.dueDate!) : null,
      isCompleted: (model.status ?? '').toLowerCase() == 'completed',
      assignedTo: model.assignedTo,
      staffMemberId: model.staffMemberId?.toString(),
      sourceEventType: model.sourceEventType,
      sourceEventId: model.sourceEventId,
      approvalRequired: model.approvalRequired ?? false,
      approvalStatus: model.approvalStatus ?? 'not_required',
      approvedBy: model.approvedBy,
      approvedAt:
          model.approvedAt != null ? DateTime.tryParse(model.approvedAt!) : null,
    );
  }

  Task _mapToModel(TaskEntity entity) {
    return Task(
      id: entity.id != null ? int.tryParse(entity.id!) : null,
      title: entity.title.value,
      description: entity.description,
      dueDate: entity.dueDate?.toIso8601String(),
      status: entity.isCompleted ? 'completed' : 'pending',
      assignedTo: entity.assignedTo,
      staffMemberId:
          entity.staffMemberId != null ? int.tryParse(entity.staffMemberId!) : null,
      sourceEventType: entity.sourceEventType,
      sourceEventId: entity.sourceEventId,
      approvalRequired: entity.approvalRequired,
      approvalStatus: entity.approvalStatus,
      approvedBy: entity.approvedBy,
      approvedAt: entity.approvedAt?.toIso8601String(),
    );
  }

  TaskEntity _withId(TaskEntity entity, String id) {
    return TaskEntity(
      id: id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      assignedTo: entity.assignedTo,
      staffMemberId: entity.staffMemberId,
      sourceEventType: entity.sourceEventType,
      sourceEventId: entity.sourceEventId,
      approvalRequired: entity.approvalRequired,
      approvalStatus: entity.approvalStatus,
      approvedBy: entity.approvedBy,
      approvedAt: entity.approvedAt,
    );
  }
}
