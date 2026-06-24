import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../post/domain/models/post_model.dart';

class FeedService {
  FeedService(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<PostModel>> getFeed({
    required String mode,
    required int page,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/feed',
        query: {'mode': mode, 'page': page, 'pageSize': pageSize},
      );
      final body = response.data!;
      final items = (body['data'] as List<dynamic>)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = body['meta']?['pagination'] as Map<String, dynamic>? ?? {};
      return PaginatedResponse(
        items: items,
        page: pagination['page'] as int? ?? page,
        pageSize: pagination['pageSize'] as int? ?? pageSize,
        hasNextPage: pagination['hasNextPage'] as bool? ?? false,
        total: pagination['total'] as int? ?? items.length,
      );
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }
}
