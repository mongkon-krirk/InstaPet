import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../post/domain/models/post_model.dart';

class DiscoverService {
  DiscoverService(this._client);

  final ApiClient _client;

  Future<List<UserModel>> searchUsers(String query, int page) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/search/users',
        query: {'q': query, 'page': page, 'pageSize': 20},
      );
      return (response.data!['data'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<List<PostModel>> getDiscoverPosts(int page) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/feed',
        query: {
          'mode': 'discover',
          'page': page,
          'pageSize': AppConstants.gridPageSize,
        },
      );
      return (response.data!['data'] as List<dynamic>)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }
}
