import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/image_processor.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../feed/presentation/controllers/feed_controller.dart';
import 'profile_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _displayName;
  late final TextEditingController _username;
  late final TextEditingController _bio;
  late bool _isPrivate;
  int? _avatarFileId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user!;
    _displayName = TextEditingController(text: user.displayName);
    _username = TextEditingController(text: user.username);
    _bio = TextEditingController(text: user.bio);
    _isPrivate = user.isPrivate;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final processed = await ImageProcessor.process(bytes, file.name);
    final multipart = MultipartFile.fromBytes(processed.bytes, filename: processed.fileName);
    final uploaded = await ref.read(postServiceProvider).uploadImages([multipart], purpose: 'avatar');
    if (uploaded.isNotEmpty) {
      setState(() => _avatarFileId = uploaded.first.id);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'displayName': _displayName.text.trim(),
        'username': _username.text.trim().toLowerCase(),
        'bio': _bio.text.trim(),
        'isPrivate': _isPrivate,
      };
      if (_avatarFileId != null) data['avatarFileId'] = _avatarFileId;

      final user = await ref.read(profileServiceProvider).updateProfile(data);
      ref.read(authControllerProvider.notifier).updateUser(user);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        leading: TextButton(
          onPressed: _saving ? null : () => context.pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w400)),
        ),
        leadingWidth: 72,
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Done'),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.divider,
                    backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                    child: user?.avatarUrl == null ? const Icon(Icons.person, size: 40, color: AppColors.textSecondary) : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _pickAvatar,
                  child: const Text('Change Profile Photo'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _profileField('Name', _displayName),
          const Divider(height: 1, indent: 16, color: AppColors.divider),
          _profileField('Username', _username),
          const Divider(height: 1, indent: 16, color: AppColors.divider),
          _profileField('Bio', _bio, maxLines: 3),
          const Divider(height: 1, color: AppColors.divider),
          SwitchListTile(
            title: const Text('Private Account', style: TextStyle(color: AppColors.textPrimary)),
            value: _isPrivate,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _isPrivate = v),
          ),
        ],
      ),
    );
  }

  Widget _profileField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
