import 'dart:math' as math;

import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ImageViewerIconView extends StatelessWidget {
  const ImageViewerIconView({
    required this.uri,
    this.overlayIcon,
    this.fit,
    super.key,
    this.isPinned = false,
    this.isPinBroken = false,
  });
  final Uri uri;

  final BoxFit? fit;
  final IconData? overlayIcon;
  final bool isPinned;
  final bool isPinBroken;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ImageViewer.basic(
            uri: uri,
            fit: fit,
          ),
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
