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
    required this.buildNotes,
    required this.getPreview,
    required this.action,
    this.onLockPage,
    super.key,
  });
  final CLMedia item;
  final String parentIdentifier;
  final StoreActions action;
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
          onMove: ac.onMove(() => action.move([media])),
          onDelete: ac.onDelete(() => action.delete([media])),
          onShare: ac.onShare(() => action.share([media])),
          onEdit: ac.onEdit(() => action.edit([media])),
          onPin: ac.onPin(() => action.togglePin([media])),
          media: item,
        ),
      ],
    );
  }
}
