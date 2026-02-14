part of 'feeding_bloc.dart';

@freezed
class FeedingState with _$FeedingState {
  const factory FeedingState.initial() = FeedingInitial;
  const factory FeedingState.loading() = FeedingLoading;
  const factory FeedingState.loaded({
    required List<FeedingScheduleEntity> schedules,
    required List<FeedingLogEntity> logs,
    required List<AnimalEntity> animals,
  }) = FeedingLoaded;
  const factory FeedingState.error({required String message}) = FeedingError;
}
