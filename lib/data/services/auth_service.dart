import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_service.dart';
import '../models/user.dart';
import '../../core/network/token_manager.dart';
import 'package:logger/logger.dart';

@LazySingleton()
class AuthService {
  final ApiService _api;
  final TokenManager _tokenManager;
  final Logger _logger = Logger();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._api, this._tokenManager);

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? farmName,
    String? location,
  }) async {
    final response = await _api.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone,
      'farm_name': farmName,
      'location': location,
    });

    await _tokenManager.saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
      expiresAt: response.data['expires_at'],
    );

    await _storage.write(
        key: 'user_id', value: response.data['user']['id'].toString());
    await _storage.write(
        key: 'user_name', value: response.data['user']['name']);
    await _storage.write(
        key: 'user_email', value: response.data['user']['email']);

    return User.fromMap(response.data['user']);
  }

  Future<User> login({required String email, required String password}) async {
    final response = await _api.post('/login', data: {
      'email': email,
      'password': password,
    });

    await _tokenManager.saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
      expiresAt: response.data['expires_at'],
    );

    await _storage.write(
        key: 'user_id', value: response.data['user']['id'].toString());
    await _storage.write(
        key: 'user_name', value: response.data['user']['name']);
    await _storage.write(
        key: 'user_email', value: response.data['user']['email']);

    _logger.i('User logged in successfully');

    return User.fromMap(response.data['user']);
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (e) {
      _logger.w('Logout API call failed', error: e);
    } finally {
      await _tokenManager.clearTokens();
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'user_name');
      await _storage.delete(key: 'user_email');
      _logger.i('User logged out');
    }
  }

  Future<User> getCurrentUser() async {
    final response = await _api.get('/user');
    return User.fromMap(response.data);
  }

  Future<User> updateCurrentUser({
    required String name,
    String? phone,
    String? location,
    String? farmName,
  }) async {
    try {
      final response = await _api.patch('/user', data: {
        'name': name,
        'phone': phone,
        'location': location,
        'farm_name': farmName,
      });

      final user = User.fromMap(response.data);
      await _storage.write(key: 'user_name', value: user.name);
      await _storage.write(key: 'user_email', value: user.email);
      if (user.id != null) {
        await _storage.write(key: 'user_id', value: user.id.toString());
      }
      return user;
    } catch (e) {
      _logger.w(
        'Remote profile update failed, applying local profile update fallback',
        error: e,
      );
      final existingId = await _storage.read(key: 'user_id');
      final existingEmail = await _storage.read(key: 'user_email');
      await _storage.write(key: 'user_name', value: name);
      if (existingEmail == null || existingEmail.isEmpty) {
        await _storage.write(key: 'user_email', value: 'unknown@local');
      }
      return User(
        id: int.tryParse(existingId ?? ''),
        name: name,
        email: existingEmail ?? 'unknown@local',
        phone: phone,
        farmName: farmName,
        location: location,
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    await _api.post('/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _api.post('/reset-password', data: {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}
