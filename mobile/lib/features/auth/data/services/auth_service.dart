import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_exception.dart';
import '../../domain/models/user_model.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<String> login(String identifier, String password) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/local',
        data: {'identifier': identifier.trim(), 'password': password},
      );
      final data = response.data;
      final jwt = data?['jwt'] as String?;
      if (jwt == null) {
        throw const ApiException(code: 'INVALID_CREDENTIALS', message: 'Login failed');
      }
      return jwt;
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/local/register',
        data: {
          'username': username.trim().toLowerCase(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      final data = response.data;
      final jwt = data?['jwt'] as String?;
      if (jwt == null) {
        throw const ApiException(code: 'VALIDATION_ERROR', message: 'Registration failed');
      }
      return jwt;
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/profiles/me');
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ApiException(code: 'UNAUTHORIZED', message: 'Not authenticated');
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    try {
      await _client.post('/account/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'newPasswordConfirmation': confirmation,
      });
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }
}
