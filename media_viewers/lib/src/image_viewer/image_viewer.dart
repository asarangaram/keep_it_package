import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class OverlayWidgets extends StatelessWidget {
  factory OverlayWidgets({
    required Widget child,
    required Alignment alignment,
    double? sizeFactor = 0.3,
    Key? key,
  }) {
    return OverlayWidgets._(
      alignment: alignment,
      widthFactor: sizeFactor,
      heightFactor: sizeFactor,
      key: key,
      child: child,
    );
  }
  const OverlayWidgets._({
    required this.alignment,
    required this.child,
    super.key,
    this.widthFactor,
    this.heightFactor,
  });
  final Alignment alignment;
  final Widget child;
  final double? widthFactor;
  final double? heightFactor;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: FittedBox(child: child),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  factory ImageViewer.basic({
    required Uri uri,
    required bool autoStart,
    required bool autoPlay,
    required bool isLocked,
    required Widget Function(String, StackTrace) errorBuilder,
    required Widget Function() loadingBuilder,
    Widget? placeHolder,
    void Function({required bool lock})? onLockPage,
    Key? key,
    BoxFit? fit,
    List<OverlayWidgets>? overlays,
  }) {
    return ImageViewer._(
      key: key,
      uri: uri,
      autoStart: autoStart,
      autoPlay: autoPlay,
      isLocked: isLocked,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      onLockPage: onLockPage,
      placeHolder: placeHolder,
      fit: fit,
      overlays: overlays,
      hasGesture: false,
    );
  }
  factory ImageViewer.guesture({
    required Uri uri,
    required bool autoStart,
    required bool autoPlay,
    required bool isLocked,
    required Widget Function(String, StackTrace) errorBuilder,
    required Widget Function() loadingBuilder,
    Widget? placeHolder,
    void Function({required bool lock})? onLockPage,
    Key? key,
    BoxFit? fit,
    List<OverlayWidgets>? overlays,
  }) {
    return ImageViewer._(
      key: key,
      uri: uri,
      autoStart: autoStart,
      autoPlay: autoPlay,
      isLocked: isLocked,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      onLockPage: onLockPage,
      placeHolder: placeHolder,
      fit: fit,
      overlays: overlays,
      hasGesture: true,
    );
  }
  const ImageViewer._({
    required this.uri,
    required this.autoStart,
    required this.autoPlay,
    required this.isLocked,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.hasGesture,
    super.key,
    this.fit,
    this.overlays,
    this.onLockPage,
    this.placeHolder,
  });

  final Uri uri;
  final bool autoStart;
  final bool autoPlay;
  final void Function({required bool lock})? onLockPage;
  final bool isLocked;
  final Widget? placeHolder;
  final Widget Function(String, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  final BoxFit? fit;
  //final GestureConfig Function(ExtendedImageState)? gestureControl;
  final List<OverlayWidgets>? overlays;
  final bool hasGesture;

  @override
  Widget build(BuildContext context) {
    final mode =
        hasGesture ? ExtendedImageMode.gesture : ExtendedImageMode.none;
    final image = switch (uri.scheme) {
      'file' => ExtendedImage.file(
          File(uri.toFilePath()),
          fit: fit ?? BoxFit.contain,
          mode: mode,
          initGestureConfigHandler:
              hasGesture ? initGestureConfigHandler : null,
        ),
      _ => ExtendedImage.network(
          uri.toString(),
          fit: fit ?? BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler:
              hasGesture ? initGestureConfigHandler : null,
        )
    };
    if (overlays?.isNotEmpty ?? false) {
      return Stack(
        children: [
          Positioned.fill(child: image),
          ...overlays!,
        ],
      );
    } else {
      return image;
    }
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
