import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_background.dart';
import 'media_controls.dart';
import 'media_viewer.dart';

class MediaView extends ConsumerStatefulWidget {
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
  ConsumerState<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends ConsumerState<MediaView> {
  late CLMedia media;
  @override
  void initState() {
    media = widget.media;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ac = widget.actionControl;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ref.read(showControlsProvider.notifier).toggleControls(),
      child: Stack(
        children: [
          const MediaBackground(),
          Positioned.fill(
            child: Hero(
              tag: '${widget.parentIdentifier} /item/${media.id}',
              child: MediaViewerRaw(
                media: media,
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
              () => TheScreenHandler.of(context).openWizard(
                context,
                [media],
                UniversalMediaSource.move,
              ),
            ),
            onDelete: ac.onDelete(() async {
              final confirmed = await ConfirmAction.deleteMediaMultiple(
                    context,
                    media: [media],
                  ) ??
                  false;
              if (!confirmed) return confirmed;
              if (context.mounted) {
                return TheScreenHandler.of(context).deleteMediaMultiple(
                  [media],
                );
              }
              return false;
            }),
            onShare: ac.onShare(
              () => TheScreenHandler.of(context)
                  .shareMediaMultiple(context, [media]),
            ),
            onEdit: (media.type == CLMediaType.video &&
                    !VideoEditServices.isSupported)
                ? null
                : ac.onEdit(
                    () async {
                      final updatedMedia =
                          await TheScreenHandler.of(context).openEditor(
                        context,
                        media,
                        canDuplicateMedia: ac.canDuplicateMedia,
                      );
                      if (updatedMedia != media && context.mounted) {
                        setState(() {
                          media = updatedMedia;
                        });
                      }

                      return true;
                    },
                  ),
            onPin: ac.onPin(
              () => TheScreenHandler.of(context).togglePinMultiple([media]),
            ),
            media: media,
          ),
        ],
      ),
    );
  }
}
