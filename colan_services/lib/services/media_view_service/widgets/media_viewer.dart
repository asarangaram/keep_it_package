import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class MediaViewerRaw extends ConsumerWidget {
  const MediaViewerRaw({
    required this.media,
    required this.onLockPage,
    required this.autoStart,
    required this.autoPlay,
    required this.isLocked,
    required this.getPreview,
    super.key,
  });
  final CLMedia media;

  final void Function({required bool lock})? onLockPage;
  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;

  final Widget Function(CLMedia media) getPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);
    return SafeArea(
      top: showControl.showNotes,
      bottom: showControl.showNotes,
      left: showControl.showNotes,
      right: showControl.showNotes,
      child: Column(
        children: [
          Expanded(
            child: switch (media.type) {
              CLMediaType.image => GetStoreManager(
                  builder: (theStore) {
                    return ImageViewService(
                      file: File(theStore.getValidMediaPath(media)),
                      onLockPage: onLockPage,
                    );
                  },
                ),
              CLMediaType.video => GetStoreManager(
                  builder: (theStore) {
                    return VideoPlayerService.player(
                      mediaPath: theStore.getValidMediaPath(media),
                      isVideo: media.type == CLMediaType.video,
                      alternate: getPreview(media),
                      autoStart: autoStart,
                      autoPlay: autoPlay,
                      inplaceControl: showControl.showNotes,
                    );
                  },
                ),
              _ => throw UnimplementedError('Not yet implemented')
            },
          ),
        ],
      ),
    );
  }
}
