import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../../application/profile_usecases.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile _getProfile;
  final Logout _logout;
  final Logger _logger = Logger();

  ProfileBloc(
    this._getProfile,
    this._logout,
  ) : super(const ProfileState.initial()) {
    on<LoadProfile>(_onLoad);
    on<LogoutProfile>(_onLogout);
  }

  Future<void> _onLoad(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileState.loading());
    try {
      final profile = await _getProfile.execute();
      emit(ProfileState.loaded(profile: profile));
    } catch (e) {
      _logger.e('error_profile_load', error: e);
      emit(const ProfileState.error(message: 'error_profile_load'));
    }
  }

  Future<void> _onLogout(
    LogoutProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _logout.execute();
      emit(const ProfileState.loggedOut());
    } catch (e) {
      _logger.e('error_profile_logout', error: e);
      emit(const ProfileState.error(message: 'error_profile_logout'));
    }
  }
}
