import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_controls.dart';
import 'media_viewer.dart';

class MediaView extends ConsumerWidget {
  const MediaView({
    required this.item,
    required this.parentIdentifier,
    required this.isLocked,
    required this.actionControl,
    required this.buildNotes,
    required this.getPreview,
    required this.storeAction,
    this.onLockPage,
    super.key,
  });
  final CLMedia item;
  final String parentIdentifier;
  final StoreActions storeAction;
  final ActionControl actionControl;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final Widget Function(CLMedia media) buildNotes;
  final Widget Function(CLMedia media) getPreview;
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
              buildNotes: buildNotes,
              getPreview: getPreview,
            ),
          ),
        ),
        MediaControls(
          onMove: ac.onMove(
            () => storeAction.openWizard([media], UniversalMediaSource.move),
          ),
          onDelete: ac.onDelete(() async {
            return ConfirmAction.deleteMedia(
              context,
              media: media,
              getPreview: getPreview,
              onConfirm: () => storeAction.delete([media], confirmed: true),
            );
          }),
          onShare: ac.onShare(() => storeAction.share([media])),
          onEdit: ac.onEdit(
            () => storeAction.openEditor(
              [media],
              canDuplicateMedia: ac.canDuplicateMedia,
            ),
          ),
          onPin: ac.onPin(() => storeAction.togglePin([media])),
          media: item,
        ),
      ],
    );
  }
}
