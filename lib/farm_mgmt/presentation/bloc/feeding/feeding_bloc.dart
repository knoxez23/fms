import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../application/animal_usecases.dart';
import '../../../application/feeding_usecases.dart';
import '../../../domain/entities/animal_entity.dart';
import '../../../domain/entities/feeding_schedule_entity.dart';
import '../../../domain/entities/feeding_log_entity.dart';

part 'feeding_event.dart';
part 'feeding_state.dart';
part 'feeding_bloc.freezed.dart';

@injectable
class FeedingBloc extends Bloc<FeedingEvent, FeedingState> {
  final GetFeedingSchedules _getSchedules;
  final GetFeedingLogs _getLogs;
  final GetAnimals _getAnimals;
  final UpdateFeedingSchedule _updateSchedule;
  final AddFeedingLog _addLog;
  final DeleteFeedingLog _deleteLog;

  FeedingBloc(
    this._getSchedules,
    this._getLogs,
    this._getAnimals,
    this._updateSchedule,
    this._addLog,
    this._deleteLog,
  ) : super(const FeedingState.initial()) {
    on<LoadFeedingData>(_onLoad);
    on<ToggleFeedingComplete>(_onToggleComplete);
    on<DeleteFeedingHistory>(_onDeleteHistory);
    on<CompleteAllFeedings>(_onCompleteAll);
  }

  Future<void> _onLoad(
    LoadFeedingData event,
    Emitter<FeedingState> emit,
  ) async {
    emit(const FeedingState.loading());
    try {
      final results = await Future.wait([
        _getSchedules.execute(),
        _getLogs.execute(),
        _getAnimals.execute(),
      ]);
      emit(FeedingState.loaded(
        schedules: results[0] as List<FeedingScheduleEntity>,
        logs: results[1] as List<FeedingLogEntity>,
        animals: results[2] as List<AnimalEntity>,
      ));
    } catch (e) {
      emit(const FeedingState.error(message: 'Failed to load feeding data'));
    }
  }

  Future<void> _onToggleComplete(
    ToggleFeedingComplete event,
    Emitter<FeedingState> emit,
  ) async {
    final current = state;
    if (current is! FeedingLoaded) return;
    final schedule =
        current.schedules.firstWhere((s) => s.id == event.scheduleId);
    final updated = FeedingScheduleEntity(
      id: schedule.id,
      animalId: schedule.animalId,
      feedType: schedule.feedType,
      quantity: schedule.quantity,
      unit: schedule.unit,
      timeOfDay: schedule.timeOfDay,
      frequency: schedule.frequency,
      startDate: schedule.startDate,
      endDate: schedule.endDate,
      notes: schedule.notes,
      completed: !schedule.completed,
    );

    try {
      await _updateSchedule.execute(updated);
      if (updated.completed) {
        await _addLog.execute(
          FeedingLogEntity(
            animalId: schedule.animalId,
            scheduleId: schedule.id,
            feedType: schedule.feedType,
            quantity: schedule.quantity,
            unit: schedule.unit,
            fedAt: DateTime.now(),
            fedBy: 'User',
            notes: 'Completed from schedule',
          ),
        );
      }
      add(const FeedingEvent.load());
    } catch (e) {
      emit(const FeedingState.error(message: 'Failed to update feeding'));
    }
  }

  Future<void> _onDeleteHistory(
    DeleteFeedingHistory event,
    Emitter<FeedingState> emit,
  ) async {
    try {
      await _deleteLog.execute(event.logId);
      add(const FeedingEvent.load());
    } catch (e) {
      emit(const FeedingState.error(message: 'Failed to delete feeding log'));
    }
  }

  Future<void> _onCompleteAll(
    CompleteAllFeedings event,
    Emitter<FeedingState> emit,
  ) async {
    final current = state;
    if (current is! FeedingLoaded) return;
    for (final schedule in current.schedules) {
      final updated = FeedingScheduleEntity(
        id: schedule.id,
        animalId: schedule.animalId,
        feedType: schedule.feedType,
        quantity: schedule.quantity,
        unit: schedule.unit,
        timeOfDay: schedule.timeOfDay,
        frequency: schedule.frequency,
        startDate: schedule.startDate,
        endDate: schedule.endDate,
        notes: schedule.notes,
        completed: true,
      );
      await _updateSchedule.execute(updated);
      await _addLog.execute(
        FeedingLogEntity(
          animalId: schedule.animalId,
          scheduleId: schedule.id,
          feedType: schedule.feedType,
          quantity: schedule.quantity,
          unit: schedule.unit,
          fedAt: DateTime.now(),
          fedBy: 'User',
          notes: 'Completed all feedings',
        ),
      );
    }
    add(const FeedingEvent.load());
  }
}
