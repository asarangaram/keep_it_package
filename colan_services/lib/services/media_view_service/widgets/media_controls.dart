import 'dart:math' as math;

import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/services/basic_page_service/widgets/page_manager.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../../../providers/show_controls.dart';

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
  final StoreEntity media;

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
        if (showControl.showMenu)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: GestureDetector(
                  onTap: PageManager.of(context).pop,
                  child: CircledIcon(
                    clIcons.closeFullscreen,
                  ),
                ),
              ),
            ),
          ),
        if (showControl.showMenu)
          if ([onEdit, onDelete, onMove, onShare, onPin]
                  .any((e) => e != null) ||
              (media.data.mediaType == CLMediaType.video))
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: GetUriVideoControls(
                  uri: media.mediaUri!, // Make sure null check before

                  builder: (
                    UriPlayControls controller,
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

  final StoreEntity media;

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
              /* if (media.data.mediaType == CLMediaType.video)
                VideoDefaultControls(
                  uri: media.mediaUri!,
                  errorBuilder: (_, __) => Container(),
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'VideoDefaultControls',
                  ),
                ), */
              if ([onEdit, onDelete, onMove, onShare, onPin]
                  .any((e) => e != null))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        CLButtonIcon.small(
                          clIcons.imageEdit,
                          color: Theme.of(context).colorScheme.surface,
                          onTap: onEdit,
                        ),
                      if (onDelete != null)
                        CLButtonIcon.small(
                          clIcons.imageDelete,
                          color: Theme.of(context).colorScheme.surface,
                          onTap: onDelete,
                        ),
                      if (onMove != null)
                        CLButtonIcon.small(
                          clIcons.imageMove,
                          color: Theme.of(context).colorScheme.surface,
                          onTap: onMove,
                        ),
                      if (onShare != null)
                        CLButtonIcon.small(
                          clIcons.imageShare,
                          color: Theme.of(context).colorScheme.surface,
                          onTap: onShare,
                        ),
                      if (onPin != null)
                        Transform.rotate(
                          angle: math.pi / 4,
                          child: CLButtonIcon.small(
                            media.data.pin != null
                                ? clIcons.pinned
                                : clIcons.notPinned,
                            color: media.data.pin != null
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
