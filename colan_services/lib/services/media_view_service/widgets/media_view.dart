import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/services/media_view_service/widgets/resizable.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:store/store.dart';

import '../../../providers/show_controls.dart';

import 'controls/goto_next_media.dart';
import 'controls/goto_prev_media.dart';
import 'controls/time_stamp.dart';
import 'controls/toggle_audio_mute.dart';
import 'controls/toggle_fullscreen.dart';
import 'controls/toggle_play.dart';
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
        await videoControls.removeVideo();
        if (media.mediaType == CLMediaType.video && media.mediaUri != null) {
          await videoControls.setVideo(
            media.mediaUri!,
            forced: false,
            autoPlay: false,
          );
        }
      }
    });
    return MediaFullScreenToggle(
      uri: media.mediaUri!,
      pageController: pageController,
      child: MediaViewer(
        heroTag: '$parentIdentifier /item/${media.id}',
        uri: media.mediaUri!,
        previewUri: media.previewUri,
        mime: media.data.mimeType!,
        onLockPage: onLockPage,
        isLocked: isLocked,
        autoStart: autoStart,
        autoPlay: autoPlay,
        brokenImage: const BrokenImage(),
        loadWidget: const GreyShimmer(),
        decoration: null,
        keepAspectRatio: true,
      ),
    );
  }
}

class MediaFullScreenToggle extends ConsumerWidget {
  const MediaFullScreenToggle({
    required this.uri,
    required this.pageController,
    required this.child,
    super.key,
  });
  final PageController pageController;
  final Uri uri;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFullScreen =
        ref.watch(showControlsProvider.select((e) => e.isFullScreen));

    final plainMedia = Center(
      child: Stack(
        children: [
          child,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  color: Colors.black54,
                  width: constraints.maxWidth, // Matches media width
                  child: ShadTheme(
                    data: ShadTheme.of(context).copyWith(
                      textTheme: ShadTheme.of(context).textTheme.copyWith(
                            small:
                                ShadTheme.of(context).textTheme.small.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                          ),
                      ghostButtonTheme: const ShadButtonTheme(
                        foregroundColor: Colors.white,
                        size: ShadButtonSize.sm,
                      ),
                    ),
                    child: Row(
                      children: [
                        FittedBox(child: OnToggleVideoPlay(uri: uri)),
                        FittedBox(child: OnToggleAudioMute(uri: uri)),
                        if (constraints.maxWidth > 240)
                          FittedBox(child: ShowTimeStamp(uri: uri)),
                        const Spacer(),
                        const FittedBox(child: OnToggleFullScreen()),
                      ],
                    ),
                  ),
                );
              },
            ),
          ), /* 
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.05,
                widthFactor: 1,
                child: InVideoMenuBar(
                  uri: uri,
                ),
              ),
            ),
          ), */
        ],
      ),
    );
    if (isFullScreen) {
      return plainMedia;
    }
    return ResizablePage(
      top: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Stack(
          children: [
            const MediaBackground(),
            Positioned.fill(
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OnGotoPrevMedia(
                      pageController: pageController,
                    ),
                  ),
                  Flexible(
                    child: plainMedia,
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
          ],
        ),
      ),
    );
  }
}
