import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../post/data/services/post_service.dart';
import '../../../post/domain/models/post_model.dart';
import '../../data/services/feed_service.dart';

class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int page;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.page = 1,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? page,
  }) =>
      FeedState(
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: error,
        page: page ?? this.page,
      );
}

class FeedController extends StateNotifier<FeedState> {
  FeedController(this._feedService, this._postService) : super(const FeedState());

  final FeedService _feedService;
  final PostService _postService;
  bool _loadingGuard = false;

  Future<void> load({bool refresh = false}) async {
    if (_loadingGuard) return;
    _loadingGuard = true;

    if (refresh) {
      state = const FeedState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _feedService.getFeed(mode: 'home', page: 1);
      state = FeedState(
        posts: result.items,
        hasMore: result.hasNextPage,
        page: 1,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } finally {
      _loadingGuard = false;
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || _loadingGuard) return;
    _loadingGuard = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      final result = await _feedService.getFeed(mode: 'home', page: nextPage);
      state = state.copyWith(
        posts: [...state.posts, ...result.items],
        hasMore: result.hasNextPage,
        page: nextPage,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    } finally {
      _loadingGuard = false;
    }
  }

  Future<void> toggleLike(int index) async {
    final post = state.posts[index];
    final optimistic = post.copyWith(
      likedByMe: !post.likedByMe,
      likesCount: post.likedByMe ? post.likesCount - 1 : post.likesCount + 1,
    );
    final posts = [...state.posts];
    posts[index] = optimistic;
    state = state.copyWith(posts: posts);

    try {
      final result = post.likedByMe
          ? await _postService.unlikePost(post.documentId)
          : await _postService.likePost(post.documentId);
      posts[index] = optimistic.copyWith(
        likedByMe: result.liked,
        likesCount: result.likesCount,
      );
      state = state.copyWith(posts: posts);
    } on ApiException {
      posts[index] = post;
      state = state.copyWith(posts: posts);
    }
  }

  Future<void> deletePost(int index) async {
    final post = state.posts[index];
    await _postService.deletePost(post.documentId);
    final posts = [...state.posts]..removeAt(index);
    state = state.copyWith(posts: posts);
  }
}

final feedServiceProvider = Provider<FeedService>(
  (ref) => FeedService(ref.watch(apiClientProvider)),
);

final postServiceProvider = Provider<PostService>(
  (ref) => PostService(ref.watch(apiClientProvider)),
);

final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>((ref) {
  return FeedController(
    ref.watch(feedServiceProvider),
    ref.watch(postServiceProvider),
  );
});
