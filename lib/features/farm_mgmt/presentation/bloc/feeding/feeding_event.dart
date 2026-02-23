part of 'feeding_bloc.dart';

@freezed
class FeedingEvent with _$FeedingEvent {
  const factory FeedingEvent.load() = LoadFeedingData;
  const factory FeedingEvent.toggleComplete({required int scheduleId}) =
      ToggleFeedingComplete;
  const factory FeedingEvent.deleteHistory({required int logId}) =
      DeleteFeedingHistory;
  const factory FeedingEvent.completeAll() = CompleteAllFeedings;
}
