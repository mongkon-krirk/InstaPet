import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/post_model.dart';

class PostCarousel extends StatefulWidget {
  const PostCarousel({super.key, required this.mediaItems});

  final List<PostMediaModel> mediaItems;

  @override
  State<PostCarousel> createState() => _PostCarouselState();
}

class _PostCarouselState extends State<PostCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItems.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Icon(Icons.image_not_supported)));
    }

    final aspect = widget.mediaItems.first.aspectRatio ?? 1.0;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: aspect,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.mediaItems.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final item = widget.mediaItems[i];
              return item.url != null
                  ? CachedNetworkImage(imageUrl: item.url!, fit: BoxFit.cover)
                  : const ColoredBox(color: Colors.grey);
            },
          ),
        ),
        if (widget.mediaItems.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('${_index + 1}/${widget.mediaItems.length}'),
          ),
      ],
    );
  }
}
