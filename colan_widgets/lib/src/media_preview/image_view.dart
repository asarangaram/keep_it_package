import 'dart:io';

import 'package:flutter/material.dart';

import '../basics/cl_icon.dart';

class ImageView extends StatelessWidget {
  const ImageView({
    required this.file,
    this.overlayIcon,
    this.fit,
    super.key,
  });
  final File file;

  final BoxFit? fit;
  final IconData? overlayIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: file.existsSync() ? Image.file(file) : const BrokenImage(),
        ),
        if (overlayIcon != null)
          Positioned.fill(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.2,
                heightFactor: 0.2,
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
