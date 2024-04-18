import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../pages/item_page.dart';

class MediaControls extends ConsumerWidget {
  const MediaControls({
    required this.media,
    super.key,
    this.onEdit,
    this.onDelete,
    this.onMove,
    this.onShare,
    this.onTap,
  });
  final CLMedia media;

  final Future<bool?> Function()? onEdit;
  final Future<bool?> Function()? onDelete;
  final Future<bool?> Function()? onMove;
  final Future<bool?> Function()? onShare;
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);
    if (!showControl) return const IgnorePointer();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: CircledIcon(
                  MdiIcons.notebook,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: CircledIcon(
                  MdiIcons.close,
                  onTap: () {
                    if (context.mounted && context.canPop()) {
                      context.pop();
                    }
                  },
                ),
              ),
            ),
          ),
          if ([onEdit, onDelete, onMove, onShare].any((e) => e != null) ||
              (media.type == CLMediaType.video))
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
                        if ([onEdit, onDelete, onMove, onShare]
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
                                    if (onEdit == null)
                                      Container()
                                    else
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
                                    if (onDelete == null)
                                      Container()
                                    else
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
                                    if (onMove == null)
                                      Container()
                                    else
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
                                    if (onShare == null)
                                      Container()
                                    else
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
        ],
      ),
    );
  }
}
