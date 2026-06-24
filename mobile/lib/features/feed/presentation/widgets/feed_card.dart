import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../post/domain/models/post_model.dart';
import '../../../post/presentation/widgets/post_caption.dart';
import '../../../post/presentation/widgets/post_carousel.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.post,
    required this.onLike,
    this.onDelete,
  });

  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final time = post.publishedAt != null
        ? DateFormat.yMMMd().add_jm().format(post.publishedAt!.toLocal())
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: GestureDetector(
            onTap: () => context.push('/profile/${post.author.username}'),
            child: UserAvatar(url: post.author.avatarUrl, radius: 18),
          ),
          title: GestureDetector(
            onTap: () => context.push('/profile/${post.author.username}'),
            child: Text(
              post.author.username,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          subtitle: time.isNotEmpty
              ? Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
              : null,
          trailing: post.canDelete
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: AppColors.icon),
                  onSelected: (v) {
                    if (v == 'delete' && onDelete != null) onDelete!();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                )
              : const Icon(Icons.more_horiz, color: AppColors.icon),
        ),
        GestureDetector(
          onTap: () => context.push('/post/${post.documentId}'),
          child: PostCarousel(mediaItems: post.mediaItems),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  post.likedByMe ? Icons.favorite : Icons.favorite_border,
                  color: post.likedByMe ? AppColors.likeRed : AppColors.icon,
                ),
                onPressed: onLike,
              ),
              IconButton(
                icon: const Icon(Icons.mode_comment_outlined, color: AppColors.icon),
                onPressed: () => context.push('/post/${post.documentId}'),
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined, color: AppColors.icon),
                onPressed: () {},
              ),
              const Spacer(),
              const IconButton(
                icon: Icon(Icons.bookmark_border, color: AppColors.icon),
                onPressed: null,
              ),
            ],
          ),
        ),
        if (post.likesCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Text(
              '${post.likesCount} likes',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: PostCaption(
              username: post.author.username,
              caption: post.caption,
            ),
          ),
        const Divider(height: 1, thickness: 0.5, color: AppColors.divider),
      ],
    );
  }
}
