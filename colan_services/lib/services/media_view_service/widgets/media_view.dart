import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:store/store.dart';

import '../../../providers/show_controls.dart';

import 'media_background.dart';

class MediaView extends ConsumerWidget {
  const MediaView({
    required this.media,
    required this.parentIdentifier,
    required this.isLocked,
    required this.autoStart,
    required this.autoPlay,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.onLockPage,
    super.key,
  });
  final StoreEntity media;

  final String parentIdentifier;

  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ref.read(showControlsProvider.notifier).toggleControls(),
      child: Stack(
        children: [
          const MediaBackground(),
          Positioned.fill(
            child: Hero(
              tag: '$parentIdentifier /item/${media.id}',
              child: Center(
                child: AspectRatio(
                  aspectRatio: (media.data.width ?? 1).toDouble() /
                      (media.data.height ?? 1),
                  child: Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.red)),
                    child: Stack(
                      children: [
                        switch (media.data.mediaType) {
                          CLMediaType.image => ImageViewer.guesture(
                              uri: media.mediaUri!,
                              onLockPage: onLockPage,
                              isLocked: isLocked,
                            ),
                          CLMediaType.video => VideoPlayer(
                              uri: media.mediaUri!,
                              autoStart: autoStart,
                              autoPlay: autoPlay,
                              onLockPage: onLockPage,
                              isLocked: isLocked,
                              placeHolder: ImageViewer.basic(
                                uri: media.previewUri!,
                              ),
                              errorBuilder: (_, __) => ImageViewer.basic(
                                uri: media.previewUri!,
                              ),
                              loadingBuilder: () => CLLoader.widget(
                                debugMessage: 'VideoPlayer',
                              ),
                            ),
                          CLMediaType.text => const BrokenImage(),
                          CLMediaType.audio => const BrokenImage(),
                          CLMediaType.file => const BrokenImage(),
                          CLMediaType.uri => const BrokenImage(),
                          CLMediaType.unknown => const BrokenImage(),
                          CLMediaType.collection =>
                            const BrokenImage(), // FIXME, How to show in Mediaview
                        },
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10..withAlpha(64),
                            ),
                            child: Row(
                              children: [
                                const Spacer(),
                                Icon(
                                  MdiIcons.fullscreen,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        //const MediaControlMenu(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          /*  Positioned(
            left: 0,
            right: 0,
            child: MediaControls(
              media: media,
            ),
          ), */
        ],
      ),
    );
  }
}

class MediaControlMenu extends ConsumerWidget {
  const MediaControlMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);
    return IconTheme(
      data: Theme.of(context).iconTheme.copyWith(color: Colors.white),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10..withAlpha(64),
        ),
        child: Row(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: ShadButton.ghost(
                onPressed: () => ref
                    .read(showControlsProvider.notifier)
                    .briefHover(timeout: const Duration(seconds: 3)),
                icon: Icon(
                  showControl.isFullScreen
                      ? MdiIcons.fullscreenExit
                      : MdiIcons.fullscreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
