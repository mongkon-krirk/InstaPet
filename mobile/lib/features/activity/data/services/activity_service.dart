import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../auth/domain/models/user_model.dart';

class ActivityItem {
  final String documentId;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final UserModel actor;
  final String? postDocumentId;
  final String? postCaption;

  const ActivityItem({
    required this.documentId,
    required this.type,
    required this.actor,
    this.isRead = false,
    this.createdAt,
    this.postDocumentId,
    this.postCaption,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
        documentId: json['documentId'] as String? ?? '',
        type: json['type'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        actor: UserModel.fromJson(json['actor'] as Map<String, dynamic>),
        postDocumentId: (json['post'] as Map<String, dynamic>?)?['documentId'] as String?,
        postCaption: (json['post'] as Map<String, dynamic>?)?['caption'] as String?,
      );
}

class ActivityService {
  ActivityService(this._client);

  final ApiClient _client;

  Future<List<ActivityItem>> getActivities(int page) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/activities',
        query: {'page': page, 'pageSize': 20},
      );
      return (response.data!['data'] as List<dynamic>)
          .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }
}
