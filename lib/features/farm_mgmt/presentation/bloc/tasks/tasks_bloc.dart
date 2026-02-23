import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../application/task_usecases.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';
part 'tasks_bloc.freezed.dart';

@injectable
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTasks _getTasks;
  final AddTask _addTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final Logger _logger = Logger();

  TasksBloc(
    this._getTasks,
    this._addTask,
    this._updateTask,
    this._deleteTask,
  ) : super(const TasksState.initial()) {
    on<LoadTasks>(_onLoad);
    on<AddTaskEvent>(_onAdd);
    on<UpdateTaskEvent>(_onUpdate);
    on<DeleteTaskEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadTasks event, Emitter<TasksState> emit) async {
    emit(const TasksState.loading());
    try {
      final tasks = await _getTasks.execute();
      emit(TasksState.loaded(tasks: tasks));
    } catch (e) {
      _logger.e('Failed to load tasks', error: e);
      emit(const TasksState.error(message: 'Failed to load tasks'));
    }
  }

  Future<void> _onAdd(AddTaskEvent event, Emitter<TasksState> emit) async {
    try {
      await _addTask.execute(event.task);
      add(const TasksEvent.load());
    } catch (e) {
      _logger.e('Failed to add task', error: e);
      emit(const TasksState.error(message: 'Failed to add task'));
    }
  }

  Future<void> _onUpdate(
    UpdateTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _updateTask.execute(event.task);
      add(const TasksEvent.load());
    } catch (e) {
      _logger.e('Failed to update task', error: e);
      emit(const TasksState.error(message: 'Failed to update task'));
    }
  }

  Future<void> _onDelete(
    DeleteTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _deleteTask.execute(event.id);
      add(const TasksEvent.load());
    } catch (e) {
      _logger.e('Failed to delete task', error: e);
      emit(const TasksState.error(message: 'Failed to delete task'));
    }
  }
}
