part of 'tasks_bloc.dart';

@freezed
class TasksEvent with _$TasksEvent {
  const factory TasksEvent.load() = LoadTasks;

  const factory TasksEvent.add({
    required TaskEntity task,
  }) = AddTaskEvent;

  const factory TasksEvent.update({
    required TaskEntity task,
  }) = UpdateTaskEvent;

  const factory TasksEvent.delete({
    required String id,
  }) = DeleteTaskEvent;
}
