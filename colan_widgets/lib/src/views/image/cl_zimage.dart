import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class CLzImage extends StatelessWidget {
  const CLzImage({required this.file, super.key});
  final File file;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.file(
      file,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (ExtendedImageState state) {
        return GestureConfig(
          inPageView: true,
          animationMaxScale: 6,
        );
      },
    );
  }
}
/**
 * 
import 'package:photo_view/photo_view.dart';
PhotoView(
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
      minScale: PhotoViewComputedScale.contained,
      imageProvider: FileImage(file),
    );
 */