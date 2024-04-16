import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CLzImage extends ConsumerStatefulWidget {
  const CLzImage({required this.file, super.key, this.onLockPage, this.onEdit});
  final File file;
  final void Function({required bool lock})? onLockPage;
  final VoidCallback? onEdit;

  @override
  ConsumerState<CLzImage> createState() => _CLzImageState();
}

class _CLzImageState extends ConsumerState<CLzImage> {
  bool isZooming = false;

  @override
  Widget build(BuildContext context) {
    final showControl = ref.watch(showControlsProvider);
    return Stack(
      children: [
        Positioned.fill(
          child: ExtendedImage.file(
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
                  if (details.totalScale != null &&
                      details.totalScale! <= 1.0) {
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
          ),
        ),
        if (showControl)
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withAlpha(192), // Color for the circular container
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CLButtonIcon.verySmall(
                      MdiIcons.pencil,
                      color: Theme.of(context)
                          .colorScheme
                          .background
                          .withAlpha(192),
                      onTap: widget.onEdit,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
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
