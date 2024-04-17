import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class MediaViewer extends StatelessWidget {
  const MediaViewer({
    required this.media,
    required this.onLockPage,
    required this.isSelected,
    super.key,
  });
  final CLMedia media;
  final void Function({required bool lock})? onLockPage;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return switch (media.type) {
      CLMediaType.image => ImageViewService(
          file: File(media.path),
          onLockPage: onLockPage,
        ),
      CLMediaType.video => VideoPlayerService(
          media: media,
          alternate: PreviewService(
            media: media,
          ),
          isSelected: isSelected,
        ),
      _ => throw UnimplementedError('Not yet implemented')
    };
  }
}
