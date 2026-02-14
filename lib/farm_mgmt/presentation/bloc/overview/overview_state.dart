part of 'overview_bloc.dart';

@freezed
class OverviewState with _$OverviewState {
  const factory OverviewState.initial() = OverviewInitial;
  const factory OverviewState.loading() = OverviewLoading;
  const factory OverviewState.loaded({
    required OverviewSummaryEntity summary,
  }) = OverviewLoaded;
  const factory OverviewState.error({required String message}) = OverviewError;
}
