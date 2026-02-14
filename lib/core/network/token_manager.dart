import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;

  TokenManager._internal();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String expiresAt,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expiresAt = DateTime.parse(expiresAt);

    await Future.wait([
      _storage.write(key: 'access_token', value: accessToken),
      _storage.write(key: 'refresh_token', value: refreshToken),
      _storage.write(key: 'expires_at', value: expiresAt),
    ]);
  }

  Future<String?> getAccessToken() async {
    if (_accessToken == null) {
      await _loadTokensFromStorage();
    }

    if (_expiresAt != null &&
        _expiresAt!.subtract(const Duration(minutes: 5)).isBefore(DateTime.now())) {
      _logger.w('Access token expired or expiring soon, refreshing...');
      await _refreshAccessToken();
    }

    return _accessToken;
  }

  Future<void> _loadTokensFromStorage() async {
    final values = await Future.wait([
      _storage.read(key: 'access_token'),
      _storage.read(key: 'refresh_token'),
      _storage.read(key: 'expires_at'),
      _storage.read(key: 'auth_token'),
    ]);

    _accessToken = values[0] ?? values[3];
    _refreshToken = values[1];
    if (values[2] != null) {
      _expiresAt = DateTime.parse(values[2]!);
    }
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final base = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';
      final dio = Dio();
      final response = await dio.post(
        '$base/v1/refresh',
        data: {'refresh_token': _refreshToken},
      );

      await saveTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        expiresAt: response.data['expires_at'],
      );

      _logger.i('Access token refreshed successfully');
    } catch (e) {
      _logger.e('Failed to refresh token', error: e);
      await clearTokens();
      throw Exception('Token refresh failed');
    }
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;

    await Future.wait([
      _storage.delete(key: 'access_token'),
      _storage.delete(key: 'refresh_token'),
      _storage.delete(key: 'expires_at'),
      _storage.delete(key: 'auth_token'),
    ]);
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }
}
