import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../image_view_service/image_view_service.dart';
import '../preview_service/view/preview.dart';
import '../video_player_service/providers/show_controls.dart';
import '../video_player_service/video_player.dart';

class MediaServices extends StatefulWidget {
  const MediaServices.preview({
    required this.media,
    super.key,
  })  : isLocked = false,
        onLockView = null,
        autoStart = false,
        isPreview = true,
        isEditable = false;
  const MediaServices.basicView({
    required this.media,
    super.key,
    this.isLocked = false,
    this.onLockView,
    this.autoStart = false,
  })  : isPreview = false,
        isEditable = false;
  final CLMedia media;
  final bool isLocked;
  final void Function({required bool lock})? onLockView;
  final bool autoStart;
  final bool isPreview;
  final bool isEditable;

  @override
  State<MediaServices> createState() => _MediaServicesState();
}

class _MediaServicesState extends State<MediaServices> {
  @override
  Widget build(BuildContext context) {
    return switch ((widget.isPreview, widget.media.type)) {
      (true, _) => PreviewService(media: widget.media),
      (false, CLMediaType.image) => ImageViewService(
          file: File(widget.media.path),
          onLockPage: widget.onLockView,
        ),
      (false, CLMediaType.video) => VideoService(
          media: widget.media,
          autoStart: widget.autoStart,
        ),
      (false, _) => throw UnimplementedError('Not yet implemented')
    };
  }
}

class VideoService extends ConsumerWidget {
  const VideoService({
    required this.media,
    this.autoStart = false,
    super.key,
  });
  final CLMedia media;
  final bool autoStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);

    return Stack(
      children: [
        Container(
          color: Colors.blue,
          child: VideoPlayerService.player(
            media: media,
            alternate: PreviewService(
              media: media,
            ),
            autoStart: autoStart,
          ),
        ),
        if (showControl.showMenu)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoPlayerService.controlMenu(media: media),
          ),
      ],
    );
  }
}
