import '../../../auth/domain/models/user_model.dart';

class PostMediaModel {
  final String documentId;
  final String? url;
  final int? width;
  final int? height;
  final double? aspectRatio;
  final int sortOrder;
  final String altText;

  const PostMediaModel({
    required this.documentId,
    this.url,
    this.width,
    this.height,
    this.aspectRatio,
    this.sortOrder = 0,
    this.altText = '',
  });

  factory PostMediaModel.fromJson(Map<String, dynamic> json) => PostMediaModel(
        documentId: json['documentId'] as String? ?? '',
        url: json['url'] as String?,
        width: json['width'] as int?,
        height: json['height'] as int?,
        aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
        sortOrder: json['sortOrder'] as int? ?? 0,
        altText: json['altText'] as String? ?? '',
      );
}

class PostModel {
  final String documentId;
  final String caption;
  final String visibility;
  final int likesCount;
  final bool likedByMe;
  final DateTime? publishedAt;
  final UserModel author;
  final List<PostMediaModel> mediaItems;
  final bool canDelete;

  const PostModel({
    required this.documentId,
    required this.caption,
    required this.visibility,
    required this.likesCount,
    required this.likedByMe,
    required this.author,
    required this.mediaItems,
    this.publishedAt,
    this.canDelete = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        documentId: json['documentId'] as String? ?? '',
        caption: json['caption'] as String? ?? '',
        visibility: json['visibility'] as String? ?? 'public',
        likesCount: json['likesCount'] as int? ?? 0,
        likedByMe: json['likedByMe'] as bool? ?? false,
        publishedAt: json['publishedAt'] != null
            ? DateTime.tryParse(json['publishedAt'] as String)
            : null,
        author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
        mediaItems: (json['mediaItems'] as List<dynamic>? ?? [])
            .map((e) => PostMediaModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        canDelete: json['canDelete'] as bool? ?? false,
      );

  PostModel copyWith({int? likesCount, bool? likedByMe}) => PostModel(
        documentId: documentId,
        caption: caption,
        visibility: visibility,
        likesCount: likesCount ?? this.likesCount,
        likedByMe: likedByMe ?? this.likedByMe,
        publishedAt: publishedAt,
        author: author,
        mediaItems: mediaItems,
        canDelete: canDelete,
      );

  String? get coverUrl => mediaItems.isNotEmpty ? mediaItems.first.url : null;
}

class PostGridItem {
  final String documentId;
  final String? coverUrl;
  final int mediaCount;
  final DateTime? publishedAt;

  const PostGridItem({
    required this.documentId,
    this.coverUrl,
    this.mediaCount = 1,
    this.publishedAt,
  });

  factory PostGridItem.fromJson(Map<String, dynamic> json) => PostGridItem(
        documentId: json['documentId'] as String? ?? '',
        coverUrl: json['coverUrl'] as String?,
        mediaCount: json['mediaCount'] as int? ?? 1,
        publishedAt: json['publishedAt'] != null
            ? DateTime.tryParse(json['publishedAt'] as String)
            : null,
      );
}
