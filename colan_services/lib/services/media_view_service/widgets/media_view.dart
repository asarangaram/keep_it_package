import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../shared_media_service/models/media_handler.dart';
import 'media_controls.dart';
import 'media_viewer.dart';

class MediaView extends ConsumerStatefulWidget {
  const MediaView({
    required this.item,
    required this.parentIdentifier,
    required this.isLocked,
    this.onLockPage,
    super.key,
  });
  final CLMedia item;
  final String parentIdentifier;

  final bool isLocked;
  final void Function({required bool lock})? onLockPage;

  @override
  ConsumerState<MediaView> createState() => MediaViewState();
}

class MediaViewState extends ConsumerState<MediaView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.item;
    return Stack(
      children: [
        Positioned.fill(
          child: Hero(
            tag: '${widget.parentIdentifier} /item/${media.id}',
            child: MediaViewerRaw(
              media: media,
              autoStart: true,
              onLockPage: widget.onLockPage,
            ),
          ),
        ),
        GetDBManager(
          builder: (dbManager) {
            final mediaHandler =
                MediaHandler(media: media, dbManager: dbManager);
            return MediaControls(
              onMove: () => mediaHandler.move(context, ref),
              onDelete: () => mediaHandler.delete(context, ref),
              onShare: () => mediaHandler.share(context, ref),
              onEdit: () => mediaHandler.edit(context, ref),
              onPin: () => mediaHandler.togglePin(context, ref),
              media: widget.item,
            );
          },
        ),
      ],
    );
  }
}
