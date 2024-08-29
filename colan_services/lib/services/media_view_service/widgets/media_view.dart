import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'media_background.dart';
import 'media_controls.dart';
import 'media_viewer.dart';

class MediaView extends ConsumerStatefulWidget {
  const MediaView({
    required this.media,
    required this.parentIdentifier,
    required this.isLocked,
    required this.actionControl,
    required this.getPreview,
    required this.autoStart,
    required this.autoPlay,
    this.onLockPage,
    super.key,
  });
  final CLMedia media;

  final String parentIdentifier;

  final ActionControl actionControl;
  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;

  final Widget Function(CLMedia media) getPreview;

  @override
  ConsumerState<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends ConsumerState<MediaView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
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
                autoStart: widget.autoStart,
                autoPlay: widget.autoPlay,
                onLockPage: widget.onLockPage,
                isLocked: widget.isLocked,
                getPreview: widget.getPreview,
              ),
            ),
          ),
          MediaControls(
            onMove: ac.onMove(
              () => TheStore.of(context).openWizard(
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
                return TheStore.of(context).deleteMediaMultiple(
                  [media],
                );
              }
              return false;
            }),
            onShare: ac.onShare(
              () => TheStore.of(context).shareMediaMultiple(context, [media]),
            ),
            onEdit: (media.type == CLMediaType.video &&
                    !VideoEditServices.isSupported)
                ? null
                : ac.onEdit(
                    () async {
                      final updatedMedia =
                          await TheStore.of(context).openEditor(
                        context,
                        media,
                        canDuplicateMedia: ac.canDuplicateMedia,
                      );
                      if (updatedMedia != media && context.mounted) {
                        setState(() {
                          //media = updatedMedia;
                        });
                      }

                      return true;
                    },
                  ),
            onPin: ac.onPin(
              () async {
                final res =
                    await TheStore.of(context).togglePinMultiple([media]);
                if (res) {
                  setState(() {});
                }
                return res;
              },
            ),
            media: media,
          ),
        ],
      ),
    );
  }
}
