part of 'tasks_bloc.dart';

@freezed
class TasksState with _$TasksState {
  const factory TasksState.initial() = TasksInitial;
  const factory TasksState.loading() = TasksLoading;
  const factory TasksState.loaded({
    required List<TaskEntity> tasks,
  }) = TasksLoaded;
  const factory TasksState.error({
    required String message,
  }) = TasksError;
}
