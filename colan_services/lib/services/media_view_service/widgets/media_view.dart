import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';


import 'media_background.dart';
import 'media_controls.dart';
import '../preview/media_preview_service.dart';

class MediaView extends StatelessWidget {
  factory MediaView({
    required CLMedia media,
    required String parentIdentifier,
    required bool autoStart,
    required bool autoPlay,
    required Widget Function(Object, StackTrace) errorBuilder,
    required Widget Function() loadingBuilder,
    bool isLocked = false,
    void Function({required bool lock})? onLockPage,
    Key? key,
  }) {
    return MediaView._(
      isPreview: false,
      key: key,
      media: media,
      parentIdentifier: parentIdentifier,
      isLocked: isLocked,
      autoStart: autoStart,
      autoPlay: autoPlay,
      onLockPage: onLockPage,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
  factory MediaView.preview(
    CLMedia media, {
    required String parentIdentifier,
  }) {
    return MediaView._(
      isPreview: true,
      media: media,
      parentIdentifier: parentIdentifier,
      isLocked: true,
      autoStart: true,
      autoPlay: true,
    );
  }
  const MediaView._({
    required this.isPreview,
    required this.media,
    required this.parentIdentifier,
    required this.isLocked,
    required this.autoStart,
    required this.autoPlay,
    this.onLockPage,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final CLMedia media;

  final String parentIdentifier;

  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final bool isPreview;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  @override
  Widget build(BuildContext context) {
    /* log(
      '${media.md5String}  isPreview: $isPreview',
      name: 'MediaView | build',
    ); */

    if (isPreview) {
      return MediaPreviewWithOverlays(
        media: media,
        parentIdentifier: parentIdentifier,
      );
    }
    if (errorBuilder == null || loadingBuilder == null) {
      throw Error();
    }
    return MediaView0(
      media: media,
      parentIdentifier: parentIdentifier,
      isLocked: isLocked,
      autoPlay: autoPlay,
      autoStart: autoStart,
      onLockPage: onLockPage,
      errorBuilder: errorBuilder!,
      loadingBuilder: loadingBuilder!,
    );
  }
}

class MediaView0 extends ConsumerWidget {
  const MediaView0({
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
  final CLMedia media;

  final String parentIdentifier;

  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);
    return GetStoreUpdater(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (theStore) {
        return GetMediaUri(
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          id: media.id!,
          builder: (mediaUri) {
            /* log(
              'id: ${media.id!} ${media.md5String} ',
              name: 'MediaView0 | build',
            ); */
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () =>
                  ref.read(showControlsProvider.notifier).toggleControls(),
              child: Stack(
                children: [
                  const MediaBackground(),
                  Positioned.fill(
                    child: Hero(
                      tag: '$parentIdentifier /item/${media.id}',
                      child: SafeArea(
                        top: showControl.showNotes,
                        bottom: showControl.showNotes,
                        left: showControl.showNotes,
                        right: showControl.showNotes,
                        child: switch (media.type) {
                          CLMediaType.image => ImageViewer.guesture(
                              uri: mediaUri!,
                              onLockPage: onLockPage,
                              isLocked: isLocked,
                            ),
                          CLMediaType.video => VideoPlayer(
                              uri: mediaUri!,
                              autoStart: autoStart,
                              autoPlay: autoPlay,
                              onLockPage: onLockPage,
                              isLocked: isLocked,
                              placeHolder: GetPreviewUri(
                                errorBuilder: BrokenImage.show,
                                loadingBuilder: () => CLLoader.widget(
                                  debugMessage: 'GetPreviewUri',
                                ),
                                id: media.id!,
                                builder: (previewUri) {
                                  return ImageViewer.basic(
                                    uri: previewUri,
                                  );
                                },
                              ),
                              errorBuilder: BrokenImage.show,
                              loadingBuilder: () => CLLoader.widget(
                                debugMessage: 'VideoPlayer',
                              ),
                            ),
                          CLMediaType.text => const BrokenImage(),
                          CLMediaType.url => const BrokenImage(),
                          CLMediaType.audio => const BrokenImage(),
                          CLMediaType.file => const BrokenImage(),
                        },
                      ),
                    ),
                  ),
                  MediaControls(
                    media: media,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
