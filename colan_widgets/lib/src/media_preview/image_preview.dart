/* // ignore: unused_import
import 'dart:io';

import 'package:flutter/material.dart';

import '../basics/cl_icon.dart';
import 'missing_preview.dart';

class UnCachedImagePreview extends StatelessWidget {
  const UnCachedImagePreview({
    required this.previewImagePath,
    this.overlayIcon,
    this.fit,
    super.key,
    this.refresh = false,
  });
  final String previewImagePath;

  final BoxFit? fit;
  final IconData? overlayIcon;
  final bool refresh;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: MissingPreview(),
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
 */
