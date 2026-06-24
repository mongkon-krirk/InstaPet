import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../domain/models/post_model.dart';

class UploadedMedia {
  final int id;
  final String documentId;
  final String url;

  const UploadedMedia({required this.id, required this.documentId, required this.url});

  factory UploadedMedia.fromJson(Map<String, dynamic> json) => UploadedMedia(
        id: json['id'] as int,
        documentId: json['documentId'] as String? ?? '${json['id']}',
        url: json['url'] as String? ?? '',
      );
}

class PostService {
  PostService(this._client);

  final ApiClient _client;

  Future<List<UploadedMedia>> uploadImages(
    List<MultipartFile> files, {
    String purpose = 'post',
    void Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'purpose': purpose,
        'files': files,
      });
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/app-media/upload',
        data: formData,
        onSendProgress: onProgress,
      );
      return (response.data!['data'] as List<dynamic>)
          .map((e) => UploadedMedia.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<PostModel> createPost({
    required String caption,
    required List<({int fileId, int sortOrder, String altText})> mediaItems,
    String visibility = 'public',
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>('/posts', data: {
        'caption': caption,
        'visibility': visibility,
        'mediaItems': mediaItems
            .map((m) => {
                  'fileId': m.fileId,
                  'sortOrder': m.sortOrder,
                  'altText': m.altText,
                })
            .toList(),
      });
      return PostModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<PostModel> getPost(String documentId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/posts/$documentId');
      return PostModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<void> deletePost(String documentId) async {
    try {
      await _client.delete('/posts/$documentId');
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<({bool liked, int likesCount})> likePost(String documentId) async {
    try {
      final response = await _client.put<Map<String, dynamic>>('/posts/$documentId/like');
      final data = response.data!['data'] as Map<String, dynamic>;
      return (
        liked: data['liked'] as bool? ?? true,
        likesCount: data['likesCount'] as int? ?? 0,
      );
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }

  Future<({bool liked, int likesCount})> unlikePost(String documentId) async {
    try {
      final response = await _client.delete<Map<String, dynamic>>('/posts/$documentId/like');
      final data = response.data!['data'] as Map<String, dynamic>;
      return (
        liked: data['liked'] as bool? ?? false,
        likesCount: data['likesCount'] as int? ?? 0,
      );
    } on DioException catch (e) {
      throw _client.mapError(e);
    }
  }
}
