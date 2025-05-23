import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/internal/resizable.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:store/store.dart';

import '../../basic_page_service/widgets/page_manager.dart';
import '../providers/media_view_state.dart';
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
    required this.onLockPage,
    super.key,
  });
  final StoreEntity media;

  final String parentIdentifier;

  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock}) onLockPage;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final VideoPlayerControls videoControls;
  final PageController pageController;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(mediaViewerStateProvider, (prev, curr) {
      if (curr.currentIndex != prev?.currentIndex) {
        final currMedia = curr.entities[curr.currentIndex];
        if (currMedia.mediaType == CLMediaType.video &&
            currMedia.mediaUri != null) {
          videoControls.setVideo(
            currMedia.mediaUri!,
            forced: false,
            autoPlay: false,
          );
        } else {
          videoControls.removeVideo();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // This seems still required
      if (autoStart && videoControls.uri != media.mediaUri) {
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
      entity: media,
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
        errorBuilder: (_, __) => const BrokenImage(),
        loadingBuilder: () => const GreyShimmer(),
        keepAspectRatio: true,
      ),
    );
  }
}

class MediaFullScreenToggle extends ConsumerWidget {
  const MediaFullScreenToggle({
    required this.entity,
    required this.pageController,
    required this.child,
    super.key,
  });
  final PageController pageController;
  final ViewerEntityMixin entity;
  final MediaViewer child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uri = entity.mediaUri!;

    final plainMedia = MediaPlayerControls(
      uri: uri,
      mime: (entity as StoreEntity).data.mimeType!,
      onClose: PageManager.of(context).pop,
      child: child,
    );

    return GetFullScreenStatus(
      builder: ({required bool isFullScreen, required bool showMenu}) {
        if (isFullScreen) {
          return plainMedia;
        }
        return ResizablePage(
          top: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Row(
              children: [
                if (!isFullScreen)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ShadButton.ghost(
                      padding: EdgeInsets.zero,
                      onPressed: () => ref
                          .read(mediaViewerStateProvider.notifier)
                          .prevPage(pageController),
                      child: const CLIcon.large(LucideIcons.chevronLeft),
                    ),
                  ),
                Flexible(child: plainMedia),
                if (!isFullScreen)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ShadButton.ghost(
                      padding: EdgeInsets.zero,
                      onPressed: () => ref
                          .read(mediaViewerStateProvider.notifier)
                          .nextPage(pageController),
                      child: const CLIcon.large(LucideIcons.chevronRight),
                    ),
                  ),
              ],
            ),
          ),
          bottom: SingleChildScrollView(
            child: Column(
              children: [
                MediaControls(media: entity as StoreEntity),
                MediaTitle(entity as StoreEntity),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MediaTitle extends ConsumerWidget {
  const MediaTitle(this.entity, {super.key});
  final StoreEntity entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        entity.data.label ?? 'Title here',
        style: ShadTheme.of(context).textTheme.h2,
        textAlign: TextAlign.start,
      ),
      subtitle: [
        if (entity.createDate != null)
          Text(
            'on ${entity.createDate!}',
            style: ShadTheme.of(context).textTheme.muted,
            textAlign: TextAlign.start,
          )
        else
          const Text(''),
      ][0],
    );
  }
}
