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
import 'media_controls.dart';

class MediaView extends ConsumerWidget {
  const MediaView({
    required this.media,
    required this.parentIdentifier,
    required this.isLocked,
    required this.autoStart,
    required this.autoPlay,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.videoControls,
    required this.pageController,
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
  final UniversalPlayControls videoControls;
  final PageController pageController;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (autoStart) {
        await videoControls.stopVideo();
        if (media.mediaType == CLMediaType.video && media.mediaUri != null) {
          await videoControls.setVideo(
            media.mediaUri!,
            forced: false,
            autoPlay: true,
          );
        }
      } else {}
    });

    return MediaFullScreenToggle(
      child: MediaWithOverlays(
        pageController: pageController,
        parentIdentifier: parentIdentifier,
        media: media,
        onLockPage: onLockPage,
        isLocked: isLocked,
        autoStart: autoStart,
        autoPlay: autoPlay,
      ),
    );
  }
}

class MediaFullScreenToggle extends ConsumerWidget {
  const MediaFullScreenToggle({
    required this.child,
    super.key,
  });
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFullScreen =
        ref.watch(showControlsProvider.select((e) => e.isFullScreen));
    if (isFullScreen) {
      return child;
    }
    return Column(
      children: [
        Flexible(child: child),
        Flexible(child: Container()),
      ],
    );
  }
}

class MediaWithOverlays extends StatelessWidget {
  const MediaWithOverlays({
    required this.pageController,
    required this.parentIdentifier,
    required this.media,
    required this.onLockPage,
    required this.isLocked,
    required this.autoStart,
    required this.autoPlay,
    super.key,
  });

  final PageController pageController;
  final String parentIdentifier;
  final StoreEntity media;
  final void Function({required bool lock})? onLockPage;
  final bool isLocked;
  final bool autoStart;
  final bool autoPlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MediaBackground(),
        Positioned.fill(
          child: Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: OnGotoPrevPage(
                  pageController: pageController,
                ),
              ),
              Flexible(
                child: Hero(
                  tag: '$parentIdentifier /item/${media.id}',
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                      child: Stack(
                        children: [
                          switch (media.data.mediaType) {
                            CLMediaType.image => ImageViewer.guesture(
                                uri: media.mediaUri!,
                                onLockPage: onLockPage,
                                isLocked: isLocked,
                                brokenImage: const BrokenImage(),
                                loadingWidget: const GreyShimmer(),
                                keepAspectRatio: true,
                              ),
                            CLMediaType.video => VideoPlayer(
                                uri: media.mediaUri!,
                                autoStart: autoStart,
                                autoPlay: autoPlay,
                                onLockPage: onLockPage,
                                isLocked: isLocked,
                                placeHolder: ImageViewer.basic(
                                  uri: media.previewUri!,
                                  brokenImage: const BrokenImage(),
                                  loadingWidget: const GreyShimmer(),
                                  keepAspectRatio: true,
                                ),
                                errorBuilder: (_, __) => ImageViewer.basic(
                                  uri: media.previewUri!,
                                  brokenImage: const BrokenImage(),
                                  loadingWidget: const GreyShimmer(),
                                  keepAspectRatio: true,
                                ),
                                loadingBuilder: GreyShimmer.new,
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
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white10..withAlpha(64),
                              ),
                              child: const MediaControlMenu(),
                            ),
                          ),
                          //const MediaControlMenu(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: OnGotoNextPage(
                  pageController: pageController,
                ),
              ),
            ],
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
          color: ShadTheme.of(context).colorScheme.background.withAlpha(192),
        ),
        child: Row(
          children: [
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ShadButton.ghost(
                onPressed: () =>
                    ref.read(showControlsProvider.notifier).fullScreenToggle(),
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
