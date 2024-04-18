import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageViewService extends ConsumerStatefulWidget {
  const ImageViewService({
    required this.file,
    super.key,
    this.onLockPage,
  });
  final File file;
  final void Function({required bool lock})? onLockPage;

  @override
  ConsumerState<ImageViewService> createState() => _CLzImageState();
}

class _CLzImageState extends ConsumerState<ImageViewService> {
  bool isZooming = false;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.file(
      widget.file,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (ExtendedImageState state) {
        return GestureConfig(
          inPageView: true,
          animationMaxScale: 10,
          minScale: 1,
          maxScale: 10,
          gestureDetailsIsChanged: (details) {
            if (details == null) return;
            if (details.totalScale != null && details.totalScale! <= 1.0) {
              if (isZooming) {
                isZooming = false;
                widget.onLockPage?.call(lock: false);
              }
            } else {
              setState(() {
                if (!isZooming) {
                  isZooming = true;
                  widget.onLockPage?.call(lock: true);
                }
              });
            }
          },
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
