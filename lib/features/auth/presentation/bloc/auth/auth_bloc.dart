import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../application/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn _signIn;
  final Register _register;
  final SignOut _signOut;
  final CheckAuthStatusUseCase _checkAuthStatus;
  final GetCurrentUser _getCurrentUser;
  final Logger _logger = Logger();

  AuthBloc(
    this._signIn,
    this._register,
    this._signOut,
    this._checkAuthStatus,
    this._getCurrentUser,
  ) : super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final user = await _signIn.execute(event.email, event.password);

      emit(AuthState.authenticated(user: user));
      _logger.i('User logged in successfully: ${user.email.value}');
    } on ArgumentError {
      emit(AuthState.error(message: 'error_auth_invalid_credentials'));
    } catch (e) {
      _logger.e('Login failed', error: e);
      String message = 'error_auth_login_failed';
      final statusCode = _extractStatusCode(e);
      if (statusCode == 422) {
        message = 'error_auth_invalid_email_password';
      } else if (statusCode == 429) {
        message = 'error_auth_too_many_attempts';
      }

      emit(AuthState.error(message: message));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final user = await _register.execute(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
        phone: event.phone,
        farmName: event.farmName,
        location: event.location,
      );

      emit(AuthState.authenticated(user: user));
      _logger.i('User registered successfully: ${user.email.value}');
    } on ArgumentError {
      emit(AuthState.error(message: 'error_auth_invalid_registration'));
    } catch (e) {
      _logger.e('Registration failed', error: e);
      String message = 'error_auth_registration_failed';
      final statusCode = _extractStatusCode(e);
      if (statusCode == 422) {
        final errors = _extractErrorMap(e);
        if (errors != null && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          }
        }
      }

      emit(AuthState.error(message: message));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await _signOut.execute();
      emit(const AuthState.unauthenticated());
      _logger.i('User logged out successfully');
    } catch (e) {
      _logger.e('Logout failed', error: e);
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final isAuth = await _checkAuthStatus.execute();

      if (isAuth) {
        final user = await _getCurrentUser.execute();
        emit(AuthState.authenticated(user: user));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      _logger.e('Auth check failed', error: e);
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAuth = await _checkAuthStatus.execute();

      if (!isAuth) {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      _logger.e('Token refresh failed', error: e);
      emit(const AuthState.unauthenticated());
    }
  }

  int? _extractStatusCode(Object error) {
    final dynamic e = error;
    final status = e.statusCode;
    return status is int ? status : null;
  }

  Map<String, dynamic>? _extractErrorMap(Object error) {
    final dynamic e = error;
    final body = e.body;
    if (body is Map<String, dynamic>) {
      final errors = body['errors'];
      if (errors is Map<String, dynamic>) return errors;
    }
    return null;
  }
}
