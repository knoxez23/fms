part of 'profile_bloc.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.load() = LoadProfile;
  const factory ProfileEvent.logout() = LogoutProfile;
}
