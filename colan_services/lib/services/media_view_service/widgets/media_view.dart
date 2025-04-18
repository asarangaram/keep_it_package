import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/services/media_view_service/widgets/cl_icons.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    this.prev,
    this.next,
  });
  final StoreEntity media;

  final String parentIdentifier;

  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget? prev;
  final Widget? next;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);
    print(showControl);
    return Stack(
      children: [
        const MediaBackground(),
        Column(
          children: [
            Flexible(
              child: Hero(
                tag: '$parentIdentifier /item/${media.id}',
                child: SafeArea(
                  child: Center(
                    child: Row(
                      children: [
                        if ((!showControl.isFullScreen) && prev != null) prev!,
                        Flexible(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Align(
                                  alignment: showControl.isFullScreen
                                      ? Alignment.center
                                      : Alignment.topCenter,
                                  child: VidoeControlButton(
                                    builder: ([controls]) {
                                      return InkWell(
                                        onHover: (_) => ref
                                            .read(
                                              showControlsProvider.notifier,
                                            )
                                            .briefHover(
                                              timeout:
                                                  const Duration(seconds: 2),
                                            ),
                                        onTap: () {
                                          controls?.onPlayPause();
                                          ref
                                              .read(
                                                showControlsProvider.notifier,
                                              )
                                              .briefHover(
                                                timeout:
                                                    const Duration(seconds: 2),
                                              );
                                        },
                                        child: switch (media.data.mediaType) {
                                          CLMediaType.image =>
                                            ImageViewer.guesture(
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
                                              errorBuilder: (_, __) =>
                                                  ImageViewer.basic(
                                                uri: media.previewUri!,
                                              ),
                                              loadingBuilder: () =>
                                                  CLLoader.widget(
                                                debugMessage: 'VideoPlayer',
                                              ),
                                              videoMenuBuilder:
                                                  showControl.showMenu
                                                      ? (context) {
                                                          return const VideoMenu();
                                                        }
                                                      : null,
                                            ),
                                          CLMediaType.text =>
                                            const BrokenImage(),
                                          CLMediaType.audio =>
                                            const BrokenImage(),
                                          CLMediaType.file =>
                                            const BrokenImage(),
                                          CLMediaType.uri =>
                                            const BrokenImage(),
                                          CLMediaType.unknown =>
                                            const BrokenImage(),
                                          CLMediaType.collection =>
                                            const BrokenImage(), // FIXME, How to show in Mediaview
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!showControl.isFullScreen && next != null) next!,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!showControl.isFullScreen)
              const Flexible(
                child: SizedBox(),
              ),
          ],
        ),
      ],
    );
  }
}

class VidoeControlButton extends ConsumerWidget {
  const VidoeControlButton({
    required this.builder,
    super.key,
  });
  final Widget Function([VideoControls? controls]) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetVideoControls(
      errorBuilder: (p0, p1) => builder(),
      loadingBuilder: builder,
      builder: builder,
    );
  }
}

class VideoMenu extends ConsumerWidget {
  const VideoMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playPauseButton = VidoeControlButton(
      builder: ([controls]) => ShadButton.ghost(
        onPressed: controls?.onPlayPause,
        child: Icon(
          controls == null
              ? videoPlayerIcons.playerPlay
              : controls.videoStatus.isPlaying
                  ? videoPlayerIcons.playerPause
                  : videoPlayerIcons.playerPlay,
          color: Colors.white,
        ),
      ),
    );

    final audioMuteButton = VidoeControlButton(
      builder: ([controls]) => ShadButton.ghost(
        onPressed: controls?.onMuteToggle,
        child: Icon(
          controls == null
              ? videoPlayerIcons.audioUnmuted
              : controls.volume == 0
                  ? videoPlayerIcons.audioMuted
                  : videoPlayerIcons.audioUnmuted,
          color: Colors.white,
        ),
      ),
    );
    final timeStamp = VidoeControlButton(
      builder: ([controls]) => Text(
        controls?.timestampFormatted ?? '__ / __',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
      ),
    );
    final fullScreen = ShadButton.ghost(
      onPressed: () =>
          ref.read(showControlsProvider.notifier).fullScreenToggle(),
      child: const Icon(
        Icons.fullscreen,
        color: Colors.white,
      ),
    );
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10..withAlpha(128),
          border: const Border(top: BorderSide()),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Row(
            children: [
              playPauseButton,
              audioMuteButton,
              timeStamp,
              const Spacer(),
              fullScreen,
            ],
          ),
        ),
      ),
    );
  }
}
