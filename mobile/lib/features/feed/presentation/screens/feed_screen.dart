import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/feed_skeleton.dart';
import '../../../../core/widgets/instapet_brand.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(feedControllerProvider.notifier).load());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedControllerProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.camera_alt_outlined, size: 24),
          onPressed: () {},
        ),
        title: const InstaPetBrand(fontSize: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedControllerProvider.notifier).load(refresh: true),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(FeedState state) {
    if (state.isLoading && state.posts.isEmpty) {
      return const FeedSkeleton();
    }
    if (state.error != null && state.posts.isEmpty) {
      return EmptyState(
        message: state.error!,
        onRetry: () => ref.read(feedControllerProvider.notifier).load(refresh: true),
      );
    }
    if (state.posts.isEmpty) {
      return const EmptyState(
        message: 'No posts yet. Follow some pet lovers or create your first post!',
        icon: Icons.photo_library_outlined,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.posts.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final post = state.posts[index];
        return FeedCard(
          post: post,
          onLike: () => ref.read(feedControllerProvider.notifier).toggleLike(index),
          onDelete: post.canDelete
              ? () async {
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
                    await ref.read(feedControllerProvider.notifier).deletePost(index);
                  }
                }
              : null,
        );
      },
    );
  }
}
