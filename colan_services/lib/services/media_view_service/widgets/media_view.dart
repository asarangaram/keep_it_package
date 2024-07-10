import 'package:colan_services/services/shared_media_service/models/on_get_media.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        OnGetMedia(
          id: media.id!,
          builder: (media, {required action}) {
            return MediaControls(
              onMove: ac.onMove(action.move),
              onDelete: ac.onDelete(action.delete),
              onShare: ac.onShare(action.share),
              onEdit: ac.onEdit(action.edit),
              onPin: ac.onPin(action.togglePin),
              media: item,
            );
          },
        ),
      ],
    );
  }
}
