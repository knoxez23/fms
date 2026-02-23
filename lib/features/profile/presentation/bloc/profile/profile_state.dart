part of 'profile_bloc.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;
  const factory ProfileState.loading() = ProfileLoading;
  const factory ProfileState.loaded({
    required UserProfileEntity profile,
  }) = ProfileLoaded;
  const factory ProfileState.loggedOut() = ProfileLoggedOut;
  const factory ProfileState.error({
    required String message,
  }) = ProfileError;
}
