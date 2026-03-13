import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:pamoja_twalima/core/services/local_notification_service.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';

class LocalSessionService {
  LocalSessionService._internal();

  static final LocalSessionService _instance = LocalSessionService._internal();
  factory LocalSessionService() => _instance;

  static const _activeUserIdKey = 'active_user_id';
  static const _activeUserEmailKey = 'active_user_email';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Logger _logger = Logger();

  Future<int?> getActiveUserId() async {
    try {
      final raw = await _storage.read(key: _activeUserIdKey);
      return int.tryParse(raw ?? '');
    } catch (error) {
      _logger.w('Active user id unavailable from secure storage', error: error);
      return null;
    }
  }

  Future<void> prepareForAuthenticatedUser({
    required int userId,
    String? email,
  }) async {
    final activeUserId = await getActiveUserId();
    if (activeUserId != null && activeUserId != userId) {
      _logger.w(
        'Authenticated user switched from $activeUserId to $userId. Clearing local session data.',
      );
      await clearSessionData();
    }

    try {
      await _storage.write(key: _activeUserIdKey, value: userId.toString());
      if (email != null && email.trim().isNotEmpty) {
        await _storage.write(key: _activeUserEmailKey, value: email.trim());
      }
    } catch (error) {
      _logger.w('Failed to persist active user session metadata', error: error);
    }
  }

  Future<void> clearSessionData() async {
    await _databaseHelper.clearLocalSessionData();
    try {
      await Future.wait([
        _storage.delete(key: _activeUserIdKey),
        _storage.delete(key: _activeUserEmailKey),
        _storage.delete(key: 'user_id'),
        _storage.delete(key: 'user_name'),
        _storage.delete(key: 'user_email'),
      ]);
    } catch (error) {
      _logger.w('Failed to clear secure session metadata', error: error);
    }
    try {
      await LocalNotificationService.instance.cancelAll();
    } on MissingPluginException {
      _logger.w('Local notifications plugin unavailable during session clear');
    }
  }
}
