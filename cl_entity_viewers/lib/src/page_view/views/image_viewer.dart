import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/uri_config.dart';
import '../providers/uri_config.dart';

class ImageViewer extends ConsumerWidget {
  const ImageViewer({
    required this.uri,
    required this.isLocked,
    required this.onLockPage,
    required this.hasGesture,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.keepAspectRatio,
    super.key,
    this.fit,
  });

  final Uri uri;
  final void Function({required bool lock})? onLockPage;
  final bool isLocked;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final bool keepAspectRatio;
  final BoxFit? fit;
  final bool hasGesture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uriConfigAsync = ref.watch(uriConfigurationProvider(uri));
    final mode =
        hasGesture ? ExtendedImageMode.gesture : ExtendedImageMode.none;

    return uriConfigAsync.when(
      data: (uriConfig) {
        return switch (uri.scheme) {
          'file' => ExtendedImage.file(
              File(uri.toFilePath()),
              fit: fit,
              mode: mode,
              initGestureConfigHandler:
                  hasGesture ? initGestureConfigHandler : null,
            ),
          _ => ExtendedImage.network(
              uri.toString(),
              fit: fit,
              mode: mode,
              initGestureConfigHandler:
                  hasGesture ? initGestureConfigHandler : null,
              cache: false,
            )
        };
      },
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }

  GestureConfig initGestureConfigHandler(ExtendedImageState state) {
    return GestureConfig(
      inPageView: true,
      animationMaxScale: 10,
      minScale: 1,
      maxScale: 10,
      gestureDetailsIsChanged: (details) {
        if (details?.totalScale == null) return;
        onLockPage?.call(lock: details!.totalScale! > 1.0);
      },
    );
  }
}

class ImageFromState extends ConsumerWidget {
  const ImageFromState(
    this.state, {
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.keepAspectRatio,
    required this.uriConfig,
    required this.mode,
    super.key,
    this.initGestureConfigHandler,
    this.fit,
  });
  final ExtendedImageState state;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final bool keepAspectRatio;
  final UriConfig uriConfig;
  final ExtendedImageMode mode;
  final BoxFit? fit;
  final GestureConfig Function(ExtendedImageState)? initGestureConfigHandler;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!keepAspectRatio) {
      return ExtendedImage(
        image: state.imageProvider,
        fit: fit,
        mode: mode,
        initGestureConfigHandler: initGestureConfigHandler,
      );
    }
    final imageInfo = state.extendedImageInfo;
    final width = imageInfo?.image.width.toDouble() ?? 1;
    final height = imageInfo?.image.height.toDouble() ?? 1;
    final aspectRatio = width / height;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: RotatedBox(
        quarterTurns: uriConfig.quarterTurns,
        child: ExtendedImage(
          image: state.imageProvider,
          fit: fit,
          mode: mode,
          initGestureConfigHandler: initGestureConfigHandler,
        ),
      ),
    );
  }
}
