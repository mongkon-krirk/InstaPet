import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/services/activity_service.dart';

final activityServiceProvider = Provider<ActivityService>(
  (ref) => ActivityService(ref.watch(apiClientProvider)),
);

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  List<ActivityItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await ref.read(activityServiceProvider).getActivities(1);
      setState(() { _items = items; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? EmptyState(message: _error!, onRetry: _load)
              : _items.isEmpty
                  ? const EmptyState(message: 'No activity yet', icon: Icons.favorite_border)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final item = _items[i];
                          final time = item.createdAt != null
                              ? DateFormat.MMMd().add_jm().format(item.createdAt!.toLocal())
                              : '';
                          final message = item.type == 'post_like'
                              ? 'liked your post'
                              : 'started following you';

                          return ListTile(
                            leading: UserAvatar(url: item.actor.avatarUrl),
                            title: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: item.actor.username,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(text: ' $message'),
                                ],
                              ),
                            ),
                            subtitle: Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            onTap: () {
                              if (item.postDocumentId != null) {
                                context.push('/post/${item.postDocumentId}');
                              } else {
                                context.push('/profile/${item.actor.username}');
                              }
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
