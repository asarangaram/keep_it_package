import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'media_background.dart';
import 'media_controls.dart';
import 'media_viewer.dart';

class MediaView extends StatefulWidget {
  const MediaView({
    required this.media,
    required this.notes,
    required this.parentIdentifier,
    required this.isLocked,
    required this.actionControl,
    required this.getPreview,
    this.onLockPage,
    this.autoStart = true,
    super.key,
  });
  final CLMedia media;
  final List<CLNote> notes;
  final String parentIdentifier;

  final ActionControl actionControl;
  final bool autoStart;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;

  final Widget Function(CLMedia media) getPreview;

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  @override
  Widget build(BuildContext context) {
    final ac = widget.actionControl;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => widget.onLockPage?.call(lock: widget.isLocked),
      child: Stack(
        children: [
          const MediaBackground(),
          Positioned.fill(
            child: Hero(
              tag: '${widget.parentIdentifier} /item/${widget.media.id}',
              child: MediaViewerRaw(
                media: widget.media,
                notes: widget.notes,
                autoStart: widget.autoStart,
                onLockPage: widget.onLockPage,
                isLocked: widget.isLocked,
                getPreview: widget.getPreview,
              ),
            ),
          ),
          MediaControls(
            onMove: ac.onMove(
              () => TheStore.of(context)
                  .openWizard([widget.media], UniversalMediaSource.move),
            ),
            onDelete: ac.onDelete(() async {
              return TheStore.of(context).deleteMediaMultiple([widget.media]);
            }),
            onShare: ac.onShare(
              () => TheStore.of(context).shareMediaMultiple([widget.media]),
            ),
            onEdit: (widget.media.type == CLMediaType.video &&
                    !VideoEditServices.isSupported)
                ? null
                : ac.onEdit(
                    () => TheStore.of(context).openEditor(
                      [widget.media],
                      canDuplicateMedia: ac.canDuplicateMedia,
                    ),
                  ),
            onPin: ac.onPin(
              () => TheStore.of(context).togglePinMultiple([widget.media]),
            ),
            media: widget.media,
          ),
        ],
      ),
    );
  }
}
