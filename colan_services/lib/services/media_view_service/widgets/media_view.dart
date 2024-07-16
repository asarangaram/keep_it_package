import 'package:colan_services/colan_services.dart';
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
    this.onLockPage,
    super.key,
  });
  final CLMedia item;
  final String parentIdentifier;

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
            () => TheStore.of(context)
                .openWizard([media], UniversalMediaSource.move),
          ),
          onDelete: ac.onDelete(() async {
            return ConfirmAction.deleteMedia(
              context,
              media: media,
              getPreview: getPreview,
              onConfirm: () =>
                  TheStore.of(context).delete([media], confirmed: true),
            );
          }),
          onShare: ac.onShare(() => TheStore.of(context).share([media])),
          onEdit: (media.type == CLMediaType.video &&
                  !VideoEditServices.isSupported)
              ? null
              : ac.onEdit(
                  () => TheStore.of(context).openEditor(
                    [media],
                    canDuplicateMedia: ac.canDuplicateMedia,
                  ),
                ),
          onPin: ac.onPin(() => TheStore.of(context).togglePin([media])),
          media: item,
        ),
      ],
    );
  }
}
