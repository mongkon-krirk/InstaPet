import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../feed/presentation/controllers/feed_controller.dart';
import '../../domain/models/post_model.dart';
import '../widgets/post_caption.dart';
import '../widgets/post_carousel.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  PostModel? _post;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final post = await ref.read(postServiceProvider).getPost(widget.documentId);
      setState(() { _post = post; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;
    final service = ref.read(postServiceProvider);
    final wasLiked = _post!.likedByMe;
    final optimistic = _post!.copyWith(
      likedByMe: !wasLiked,
      likesCount: wasLiked ? _post!.likesCount - 1 : _post!.likesCount + 1,
    );
    setState(() => _post = optimistic);
    try {
      final result = wasLiked
          ? await service.unlikePost(_post!.documentId)
          : await service.likePost(_post!.documentId);
      setState(() => _post = optimistic.copyWith(
            likedByMe: result.liked,
            likesCount: result.likesCount,
          ));
    } catch (_) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(message: _error ?? 'Post not found', onRetry: _load),
      );
    }

    final post = _post!;
    return Scaffold(
      appBar: AppBar(
        title: Text(post.author.username),
        actions: [
          if (post.canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete post?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(postServiceProvider).deletePost(post.documentId);
                  ref.read(feedControllerProvider.notifier).load(refresh: true);
                  if (mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: ListView(
        children: [
          PostCarousel(mediaItems: post.mediaItems),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.likedByMe ? Icons.favorite : Icons.favorite_border,
                    color: post.likedByMe ? AppColors.likeRed : AppColors.icon,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('${post.likesCount} likes'),
              ],
            ),
          ),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: PostCaption(
                username: post.author.username,
                caption: post.caption,
              ),
            ),
        ],
      ),
    );
  }
}
