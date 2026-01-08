import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../auth/auth_state.dart';

class ApiException implements Exception {
  final int? statusCode;
  final dynamic body;
  final String message;

  ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message, body: $body)';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService._internal() {
    final base = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';
    _dio = Dio(BaseOptions(
      baseUrl: base, // read from .env
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        String? token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // If unauthorized, remove local token so app can recover to login
        try {
          final status = e.response?.statusCode;
          debugPrint('DIO ERROR [$status]: ${e.response?.data}');
          if (status == 401) {
            await _storage.delete(key: 'auth_token');
            // signal unauthenticated to the app
            AuthState.isAuthenticated.value = false;
          }
        } catch (_) {}
        handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  // Generic GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      developer.log('GET $path failed: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException('GET request failed', statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  // Generic POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      developer.log('POST $path failed: ${e.response?.statusCode} ${e.response?.data} -- payload: $data');
      throw ApiException('POST request failed', statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  // Generic PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      developer.log('PUT $path failed: ${e.response?.statusCode} ${e.response?.data} -- payload: $data');
      throw ApiException('PUT request failed', statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  // Generic DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      developer.log('DELETE $path failed: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException('DELETE request failed', statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }
}