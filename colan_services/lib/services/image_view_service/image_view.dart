import 'dart:io';
import 'dart:math' as math;

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../internal/widgets/broken_image.dart';

class ImageViewerBasic extends StatelessWidget {
  const ImageViewerBasic({
    required this.uri,
    this.overlayIcon,
    this.fit,
    super.key,
    this.isFullScreen = false,
    this.isPinned = false,
    this.isPinBroken = false,
  });
  final Uri uri;
  final bool isFullScreen;

  final BoxFit? fit;
  final IconData? overlayIcon;
  final bool isPinned;
  final bool isPinBroken;

  @override
  Widget build(BuildContext context) {
    print(uri.path);
    return Stack(
      children: [
        Positioned.fill(
          child: switch (uri.scheme) {
            'file' => Image.file(
                File(uri.path),
                fit: fit,
              ),
            _ => Image.network(
                uri.toString(),
                fit: fit,
              )
          },
        ),
        if (isPinned)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: FractionallySizedBox(
                widthFactor: 0.3,
                heightFactor: 0.3,
                child: FittedBox(
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: CLIcon.veryLarge(
                      isPinBroken ? MdiIcons.pinOffOutline : MdiIcons.pin,
                      color: isPinBroken ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
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
                          .onSurface
                          .withAlpha(192), // Color for the circular container
                    ),
                    child: CLIcon.veryLarge(
                      overlayIcon!,
                      color: CLTheme.of(context).colors.iconColorTransparent,
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
