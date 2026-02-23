import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';
import '../../core/network/token_manager.dart';

class ApiException implements Exception {
  final int? statusCode;
  final dynamic body;
  final String message;

  ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message, body: $body)';
}

@LazySingleton()
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final TokenManager _tokenManager = TokenManager();
  final Logger _logger = Logger();

  ApiService._internal() {
    final base = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';
    _dio = Dio(BaseOptions(
      baseUrl: '$base/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenManager.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        final status = e.response?.statusCode;

        if (status == 401) {
          _logger.w('401 Unauthorized - clearing tokens');
          await _tokenManager.clearTokens();
        }

        if (status != null && status >= 500) {
          _logger.e('Server error [$status]', error: e.response?.data);
        }

        handler.next(e);
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => _logger.d(obj),
      ));
    }
  }

  Dio get dio => _dio;

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      developer.log(
          'GET $path failed: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException('GET request failed',
          statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      developer.log(
          'POST $path failed: ${e.response?.statusCode} ${e.response?.data} -- payload: $data');
      throw ApiException('POST request failed',
          statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      developer.log(
          'PUT $path failed: ${e.response?.statusCode} ${e.response?.data} -- payload: $data');
      throw ApiException('PUT request failed',
          statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      developer.log(
          'PATCH $path failed: ${e.response?.statusCode} ${e.response?.data} -- payload: $data');
      throw ApiException('PATCH request failed',
          statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      developer.log(
          'DELETE $path failed: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException('DELETE request failed',
          statusCode: e.response?.statusCode, body: e.response?.data);
    }
  }
}
