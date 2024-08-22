import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer.basic({
    required this.uri,
    super.key,
    this.fit,
  }) : gestureControl = null;
  const ImageViewer.gesture({
    required this.uri,
    required GestureConfig Function(ExtendedImageState)
        initGestureConfigHandler,
    super.key,
    this.fit,
  }) : gestureControl = initGestureConfigHandler;
  final Uri uri;
  final BoxFit? fit;
  final GestureConfig Function(ExtendedImageState)? gestureControl;

  @override
  Widget build(BuildContext context) {
    final mode = gestureControl != null
        ? ExtendedImageMode.gesture
        : ExtendedImageMode.none;
    return switch (uri.scheme) {
      'file' => ExtendedImage.file(
          File(uri.path),
          fit: fit ?? BoxFit.contain,
          mode: mode,
          initGestureConfigHandler: gestureControl,
        ),
      _ => ExtendedImage.network(
          uri.toString(),
          fit: fit ?? BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: gestureControl,
        )
    };
  }
}
