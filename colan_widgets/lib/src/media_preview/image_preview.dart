import 'dart:io';

import 'package:flutter/material.dart';

import '../basics/cl_icon.dart';

class CachedImagePreview extends StatelessWidget {
  const CachedImagePreview({
    required this.previewImagePath,
    this.overlayIcon,
    this.fit,
    super.key,
    this.refresh = false,
  });
  final String previewImagePath;
  static Map<String, Widget> cached = {};

  final BoxFit? fit;
  final IconData? overlayIcon;
  final bool refresh;

  @override
  Widget build(BuildContext context) {
    final key = '$previewImagePath ${overlayIcon.hashCode} ${fit.hashCode}';
    if (!cached.containsKey(key) || refresh) {
      cached[key] = Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(previewImagePath),
              fit: fit,
              filterQuality: FilterQuality.none,
            ),
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
    return cached[key]!;
  }
}
