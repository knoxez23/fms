part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeInitial;
  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.loaded({required DashboardData data}) = HomeLoaded;
  const factory HomeState.error({required String message}) = HomeError;
}
