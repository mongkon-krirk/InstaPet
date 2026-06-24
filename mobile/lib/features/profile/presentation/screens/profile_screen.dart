import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../post/domain/models/post_model.dart';
import '../../data/services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.watch(apiClientProvider)),
);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.username});

  final String? username;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserModel? _user;
  List<PostGridItem> _posts = [];
  bool _loading = true;
  bool _isPrivate = false;
  String? _error;

  bool get _isMe {
    final me = ref.read(authControllerProvider).user;
    return widget.username == null || widget.username == me?.username;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final service = ref.read(profileServiceProvider);
      final username = widget.username ?? ref.read(authControllerProvider).user!.username;
      final user = _isMe && widget.username == null
          ? ref.read(authControllerProvider).user!
          : await service.getProfile(username);
      final result = await service.getUserPosts(username, 1);
      setState(() {
        _user = user;
        _posts = result;
        _isPrivate = user.isPrivate && !_isMe;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleFollow() async {
    if (_user == null) return;
    final service = ref.read(profileServiceProvider);
    final result = _user!.isFollowing
        ? await service.unfollow(_user!.username)
        : await service.follow(_user!.username);
    setState(() {
      _user = _user!.copyWith(
        isFollowing: result.following,
        followersCount: result.followersCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(message: _error ?? 'Profile not found', onRetry: _load),
      );
    }

    final user = _user!;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
        actions: [
          if (_isMe)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(user)),
            if (_isPrivate)
              const SliverFillRemaining(
                child: EmptyState(
                  message: 'This account is private',
                  icon: Icons.lock_outline,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(2),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final post = _posts[i];
                      return GestureDetector(
                        onTap: () => context.push('/post/${post.documentId}'),
                        child: post.coverUrl != null
                            ? CachedNetworkImage(imageUrl: post.coverUrl!, fit: BoxFit.cover)
                            : const ColoredBox(color: Colors.grey),
                      );
                    },
                    childCount: _posts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(url: user.avatarUrl, radius: 40),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat('Posts', user.postsCount),
                    _stat('Followers', user.followersCount),
                    _stat('Following', user.followingCount),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          if (user.bio.isNotEmpty)
            Text(user.bio, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          const SizedBox(height: 12),
          if (_isMe)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/profile/edit'),
                child: const Text('Edit Profile'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: user.isFollowing
                  ? OutlinedButton(
                      onPressed: _toggleFollow,
                      child: const Text('Following'),
                    )
                  : ElevatedButton(
                      onPressed: _toggleFollow,
                      child: const Text('Follow'),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
      ],
    );
  }
}
