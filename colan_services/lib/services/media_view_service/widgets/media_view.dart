import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../shared_media_service/models/media_handler.dart';
import '../models/action_control.dart';
import 'media_controls.dart';
import 'media_viewer.dart';

class MediaView extends ConsumerWidget {
  const MediaView({
    required this.item,
    required this.parentIdentifier,
    required this.isLocked,
    required this.actionControl,
    this.onLockPage,
    super.key,
  });
  final CLMedia item;
  final String parentIdentifier;
  final ActionControl actionControl;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ac = actionControl;
    final media = item;
    return Stack(
      children: [
        Positioned.fill(
          child: Hero(
            tag: '$parentIdentifier /item/${media.id}',
            child: MediaViewerRaw(
              media: media,
              autoStart: true,
              onLockPage: onLockPage,
              isLocked: isLocked,
            ),
          ),
        ),
        GetDBManager(
          builder: (dbManager) {
            final mediaHandler =
                MediaHandler(media: media, dbManager: dbManager);
            return MediaControls(
              onMove: ac.onMove(() => mediaHandler.move(context, ref)),
              onDelete: ac.onDelete(() => mediaHandler.delete(context, ref)),
              onShare: ac.onShare(() => mediaHandler.share(context, ref)),
              onEdit: ac.onEdit(() => mediaHandler.edit(context, ref)),
              onPin: ac.onPin(() => mediaHandler.togglePin(context, ref)),
              media: item,
            );
          },
        ),
      ],
    );
  }
}
