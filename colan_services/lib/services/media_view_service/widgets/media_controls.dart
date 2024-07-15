import 'dart:math' as math;

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store_model/store_model.dart';

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
                child: ColoredBox(
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
                            VideoPlayerService.controlMenu(
                              media: media,
                            ),
                          if ([onEdit, onDelete, onMove, onShare, onPin]
                              .any((e) => e != null))
                            VideoPlayerService.playStateBuilder(
                              media: media,
                              builder: ({required bool isPlaying}) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (onEdit != null)
                                        CLButtonIcon.small(
                                          MdiIcons.pencil,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          disabledColor: isPlaying
                                              ? Theme.of(context).disabledColor
                                              : null,
                                          onTap: isPlaying ? null : onEdit,
                                        ),
                                      if (onDelete != null)
                                        CLButtonIcon.small(
                                          Icons.delete_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          disabledColor: isPlaying
                                              ? Theme.of(context).disabledColor
                                              : null,
                                          onTap: isPlaying ? null : onDelete,
                                        ),
                                      if (onMove != null)
                                        CLButtonIcon.small(
                                          MdiIcons.imageMove,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          disabledColor: isPlaying
                                              ? Theme.of(context).disabledColor
                                              : null,
                                          onTap: isPlaying ? null : onMove,
                                        ),
                                      if (onShare != null)
                                        CLButtonIcon.small(
                                          MdiIcons.share,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          disabledColor: isPlaying
                                              ? Theme.of(context).disabledColor
                                              : null,
                                          onTap: isPlaying ? null : onShare,
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
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                            disabledColor: isPlaying
                                                ? Theme.of(context)
                                                    .disabledColor
                                                : null,
                                            onTap: isPlaying ? null : onPin,
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
                            ),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
