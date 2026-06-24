import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../constants/app_constants.dart';

class ProcessedImage {
  final Uint8List bytes;
  final String fileName;
  final int width;
  final int height;

  const ProcessedImage({
    required this.bytes,
    required this.fileName,
    required this.width,
    required this.height,
  });
}

class ImageProcessor {
  static Future<ProcessedImage> process(Uint8List input, String originalName) async {
    var image = img.decodeImage(input);
    if (image == null) {
      throw Exception('Could not decode image');
    }

    image = img.bakeOrientation(image);

    final maxDim = AppConstants.maxImageDimension;
    if (image.width > maxDim || image.height > maxDim) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? maxDim : null,
        height: image.height > image.width ? maxDim : null,
      );
    }

    final bytes = Uint8List.fromList(
      img.encodeJpg(image, quality: AppConstants.jpegQuality),
    );

    final baseName = originalName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return ProcessedImage(
      bytes: bytes,
      fileName: '$baseName.jpg',
      width: image.width,
      height: image.height,
    );
  }
}
