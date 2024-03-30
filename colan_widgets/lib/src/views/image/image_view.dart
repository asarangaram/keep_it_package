import 'dart:io';

import 'package:flutter/material.dart';

import '../../basics/cl_icon.dart';

class ImageViewerBasic extends StatelessWidget {
  const ImageViewerBasic({
    required this.file,
    this.overlayIcon,
    this.fit,
    super.key,
    this.isFullScreen = false,
  });
  final File file;
  final bool isFullScreen;

  final BoxFit? fit;
  final IconData? overlayIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: file.existsSync()
              ? Image.file(
                  file,
                  fit: fit,
                )
              : const Center(child: BrokenImage()),
        ),
        if (overlayIcon != null)
          Positioned.fill(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.3,
                heightFactor: 0.3,
                child: FittedBox(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withAlpha(192), // Color for the circular container
                    ),
                    child: CLIcon.veryLarge(
                      overlayIcon!,
                      color: Theme.of(context)
                          .colorScheme
                          .background
                          .withAlpha(192),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class BrokenImage extends StatelessWidget {
  const BrokenImage({
    super.key,
  });
  static Widget? placeHolder;

  @override
  Widget build(BuildContext context) {
    return placeHolder ??= AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.square(
          dimension: 64,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: CLIcon.large(
                  Icons.broken_image_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* 
class MediaPlaceHolder extends StatelessWidget {
  const MediaPlaceHolder({
    required this.media,
    super.key,
  });

  final CLMedia media;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.square(
          dimension: 60 + 16,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: Text(
                  path.basename(media.path),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */
