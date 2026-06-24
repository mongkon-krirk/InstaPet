import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../post/domain/models/post_model.dart';
import '../../data/services/discover_service.dart';

final discoverServiceProvider = Provider<DiscoverService>(
  (ref) => DiscoverService(ref.watch(apiClientProvider)),
);

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<UserModel> _users = [];
  List<PostModel> _posts = [];
  bool _loading = false;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadGrid();
  }

  Future<void> _loadGrid() async {
    setState(() { _loading = true; _error = null; });
    try {
      final posts = await ref.read(discoverServiceProvider).getDiscoverPosts(1);
      setState(() { _posts = posts; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: AppConstants.searchDebounceMs), () async {
      setState(() { _query = value.trim(); _loading = true; });
      if (_query.length < 2) {
        await _loadGrid();
        return;
      }
      try {
        final users = await ref.read(discoverServiceProvider).searchUsers(_query, 1);
        setState(() { _users = users; _posts = []; _loading = false; });
      } catch (e) {
        setState(() { _error = e.toString(); _loading = false; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? EmptyState(message: _error!, onRetry: _loadGrid)
                    : _query.length >= 2
                        ? _buildUserList()
                        : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (_users.isEmpty) {
      return const EmptyState(message: 'No users found', icon: Icons.person_search);
    }
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (_, i) {
        final user = _users[i];
        return ListTile(
          leading: UserAvatar(url: user.avatarUrl),
          title: Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          subtitle: Text('@${user.username}', style: const TextStyle(color: AppColors.textSecondary)),
          onTap: () => context.push('/profile/${user.username}'),
        );
      },
    );
  }

  Widget _buildGrid() {
    if (_posts.isEmpty) {
      return const EmptyState(message: 'No public posts yet', icon: Icons.grid_on);
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _posts.length,
      itemBuilder: (_, i) {
        final post = _posts[i];
        final cover = post.coverUrl;
        return GestureDetector(
          onTap: () => context.push('/post/${post.documentId}'),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (cover != null)
                CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover)
              else
                const ColoredBox(color: AppColors.divider),
              if (post.mediaItems.length > 1)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.collections, color: Colors.white, size: 18),
                ),
            ],
          ),
        );
      },
    );
  }
}
