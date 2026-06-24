import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/image_processor.dart';
import '../../../feed/presentation/controllers/feed_controller.dart';
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  final List<ProcessedImage> _images = [];
  double _uploadProgress = 0;
  bool _submitting = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(
      limit: AppConstants.maxImagesPerPost - _images.length,
    );
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final processed = await ImageProcessor.process(bytes, file.name);
      setState(() => _images.add(processed));
    }
  }

  Future<void> _submit() async {
    if (_images.isEmpty) return;
    setState(() => _submitting = true);

    try {
      final multipartFiles = _images
          .map((img) => MultipartFile.fromBytes(img.bytes, filename: img.fileName))
          .toList();

      final postService = ref.read(postServiceProvider);
      final uploaded = await postService.uploadImages(
        multipartFiles,
        onProgress: (sent, total) {
          if (total > 0) setState(() => _uploadProgress = sent / total);
        },
      );

      await postService.createPost(
        caption: _captionController.text.trim(),
        mediaItems: [
          for (var i = 0; i < uploaded.length; i++)
            (fileId: uploaded[i].id, sortOrder: i, altText: ''),
        ],
      );

      ref.read(feedControllerProvider.notifier).load(refresh: true);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: _submitting || _images.isEmpty ? null : _submit,
            child: _submitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Share'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_submitting)
            LinearProgressIndicator(value: _uploadProgress > 0 ? _uploadProgress : null),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._images.map((img) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Image.memory(img.bytes, width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _images.remove(img)),
                            ),
                          ),
                        ],
                      ),
                    )),
                if (_images.length < AppConstants.maxImagesPerPost)
                  InkWell(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.add_photo_alternate_outlined),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              hintText: 'Write a caption...',
              border: InputBorder.none,
            ),
            maxLines: 4,
            maxLength: 500,
          ),
        ],
      ),
    );
  }
}
