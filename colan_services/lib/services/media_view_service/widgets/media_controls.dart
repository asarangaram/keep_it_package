import 'dart:math' as math;

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';
import 'package:video_player/video_player.dart';

import '../../video_player_service/models/video_player_state.dart';
import '../../video_player_service/views/get_video_controller.dart';

class MediaControls extends ConsumerWidget {
  const MediaControls({
    required this.media,
    super.key,
    this.onEdit,
    this.onDelete,
    this.onMove,
    this.onShare,
    this.onTap,
    this.onPin,
  });
  final CLMedia media;

  final Future<bool?> Function()? onEdit;
  final Future<bool?> Function()? onDelete;
  final Future<bool?> Function()? onMove;
  final Future<bool?> Function()? onShare;
  final Future<bool?> Function()? onTap;
  final Future<bool?> Function()? onPin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);

    return Stack(
      children: [
        if (showControl.showMenu || showControl.showNotes)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: CircledIcon(
                  showControl.showNotes
                      ? MdiIcons.notebookCheck
                      : MdiIcons.notebookEdit,
                  onTap: () {
                    showControl.showNotes
                        ? ref.read(showControlsProvider.notifier).hideNotes()
                        : ref.read(showControlsProvider.notifier).showNotes();
                  },
                ),
              ),
            ),
          ),
        if (showControl.showMenu || showControl.showNotes)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: CLPopScreen.onTap(
                  child: CircledIcon(
                    MdiIcons.close,
                  ),
                ),
              ),
            ),
          ),
        if (showControl.showMenu)
          if ([onEdit, onDelete, onMove, onShare, onPin]
                  .any((e) => e != null) ||
              (media.type == CLMediaType.video))
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: GetVideoController(
                  errorBuilder: (e, st) {
                    return ControllerMenu(
                      media: media,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      onMove: onMove,
                      onShare: onShare,
                      onPin: onPin,
                    );
                  },
                  loadingBuilder: () {
                    return ControllerMenu(
                      media: media,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      onMove: onMove,
                      onShare: onShare,
                      onPin: onPin,
                    );
                  },
                  builder: (
                    VideoPlayerState state,
                    VideoPlayerController controller,
                  ) {
                    return ControllerMenu(
                      media: media,
                      onEdit: onEdit == null
                          ? null
                          : () async {
                              await controller.pause();
                              return onEdit?.call();
                            },
                      onDelete: onDelete == null
                          ? null
                          : () async {
                              await controller.pause();
                              return onDelete?.call();
                            },
                      onMove: onMove == null
                          ? null
                          : () async {
                              await controller.pause();
                              return onMove?.call();
                            },
                      onShare: onShare == null
                          ? null
                          : () async {
                              await controller.pause();
                              return onShare?.call();
                            },
                      onPin: onPin == null
                          ? null
                          : () async {
                              await controller.pause();
                              return onPin?.call();
                            },
                    );
                  },
                ),
              ),
            ),
      ],
    );
  }
}

class ControllerMenu extends StatelessWidget {
  const ControllerMenu({
    required this.media,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
    required this.onShare,
    required this.onPin,
    super.key,
  });

  final CLMedia media;

  final Future<bool?> Function()? onEdit;
  final Future<bool?> Function()? onDelete;
  final Future<bool?> Function()? onMove;
  final Future<bool?> Function()? onShare;
  final Future<bool?> Function()? onPin;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (media.type == CLMediaType.video)
                GetStoreManager(
                  builder: (theStore) {
                    return VideoPlayerService.controlMenu(
                      mediaPath: theStore.getValidMediaPath(media),
                      isVideo: media.type == CLMediaType.video,
                    );
                  },
                ),
              if ([onEdit, onDelete, onMove, onShare, onPin]
                  .any((e) => e != null))
                GetStoreManager(
                  builder: (theStore) {
                    return VideoPlayerService.playStateBuilder(
                      mediaPath: theStore.getValidMediaPath(media),
                      isVideo: media.type == CLMediaType.video,
                      builder: ({required bool isPlaying}) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onEdit != null)
                                CLButtonIcon.small(
                                  MdiIcons.pencil,
                                  color: Theme.of(context).colorScheme.surface,
                                  onTap: onEdit,
                                ),
                              if (onDelete != null)
                                CLButtonIcon.small(
                                  Icons.delete_rounded,
                                  color: Theme.of(context).colorScheme.surface,
                                  onTap: onDelete,
                                ),
                              if (onMove != null)
                                CLButtonIcon.small(
                                  MdiIcons.imageMove,
                                  color: Theme.of(context).colorScheme.surface,
                                  onTap: onMove,
                                ),
                              if (onShare != null)
                                CLButtonIcon.small(
                                  MdiIcons.share,
                                  color: Theme.of(context).colorScheme.surface,
                                  onTap: onShare,
                                ),
                              if (onPin != null)
                                Transform.rotate(
                                  angle: math.pi / 4,
                                  child: CLButtonIcon.small(
                                    media.pin != null
                                        ? MdiIcons.pin
                                        : MdiIcons.pinOutline,
                                    color: media.pin != null
                                        ? Colors.blue
                                        : Theme.of(context).colorScheme.surface,
                                    onTap: onPin,
                                  ),
                                ),
                            ]
                                .map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(
                                      right: 16,
                                    ),
                                    child: e,
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
