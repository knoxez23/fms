import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_service.dart';
import '../network/api_error.dart';

class AuthService {
  final ApiService _api = ApiService();
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['token'] != null) {
        // Save token and user info securely
        await _storage.write(key: 'auth_token', value: response.data['token']);
        await _storage.write(key: 'user_id', value: response.data['user']['id'].toString());
        await _storage.write(key: 'user_name', value: response.data['user']['name']);
        await _storage.write(key: 'user_email', value: response.data['user']['email']);
      }

      return response.data;
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    } catch (e) {
      throw ApiError(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? farmName,
    String? location,
  }) async {
    try {
      final response = await _api.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (farmName != null && farmName.isNotEmpty) 'farm_name': farmName,
        if (location != null && location.isNotEmpty) 'location': location,
      });

      if (response.data['token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['token']);
        await _storage.write(key: 'user_id', value: response.data['user']['id'].toString());
        await _storage.write(key: 'user_name', value: response.data['user']['name']);
        await _storage.write(key: 'user_email', value: response.data['user']['email']);
      }

      return response.data;
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    } catch (e) {
      throw ApiError(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (e) {
      // Log error but don't throw - still clear local data
      print('Logout error: $e');
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}