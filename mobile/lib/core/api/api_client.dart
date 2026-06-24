import 'package:dio/dio.dart';

import '../../app/config/env.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required Future<void> Function() onUnauthorized,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    return _dio.get<T>(path, queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> patch<T>(String path, {dynamic data}) {
    return _dio.patch<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }

  ApiException mapError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['error'] != null) {
      final err = data['error'] as Map<String, dynamic>;
      return ApiException(
        code: err['code'] as String? ?? 'UNKNOWN',
        message: err['message'] as String? ?? 'Request failed',
        statusCode: error.response?.statusCode,
      );
    }
    return ApiException(
      code: 'NETWORK_ERROR',
      message: error.message ?? 'Network error',
      statusCode: error.response?.statusCode,
    );
  }
}
