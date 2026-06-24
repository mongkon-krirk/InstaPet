import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../post/domain/models/post_model.dart';

class ProfileService {
  ProfileService(this._client);

  final ApiClient _client;

  Future<UserModel> getProfile(String username) async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/profiles/$username');
      return UserModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _client.patch<Map<String, dynamic>>('/profiles/me', data: data);
      return UserModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<List<PostGridItem>> getUserPosts(String username, int page, {int pageSize = 18}) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/profiles/$username/posts',
        query: {'page': page, 'pageSize': pageSize},
      );
      return (response.data!['data'] as List<dynamic>)
          .map((e) => PostGridItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<({bool following, int followersCount})> follow(String username) async {
    try {
      final response = await _client.put<Map<String, dynamic>>('/profiles/$username/follow');
      final data = response.data!['data'] as Map<String, dynamic>;
      return (
        following: data['following'] as bool? ?? true,
        followersCount: data['followersCount'] as int? ?? 0,
      );
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<({bool following, int followersCount})> unfollow(String username) async {
    try {
      final response = await _client.delete<Map<String, dynamic>>('/profiles/$username/follow');
      final data = response.data!['data'] as Map<String, dynamic>;
      return (
        following: data['following'] as bool? ?? false,
        followersCount: data['followersCount'] as int? ?? 0,
      );
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }
}
