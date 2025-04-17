import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final showControl = ref.watch(showControlsProvider);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ref.read(showControlsProvider.notifier).toggleControls(),
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
                child: switch (media.data.mediaType) {
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
                      errorBuilder: BrokenImage.show,
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
              ),
            ),
          ),
          MediaControls(
            media: media,
          ),
        ],
      ),
    );
  }
}
