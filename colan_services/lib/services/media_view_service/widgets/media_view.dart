import 'package:colan_services/services/media_view_service/widgets/media_preview_service.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:content_store/extensions/ext_cldirectories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:media_viewers/media_viewers.dart';
import 'package:store/store.dart';

import '../../basic_page_service/dialogs.dart';
import '../../basic_page_service/page_manager.dart';

import '../../incoming_media_service/models/cl_shared_media.dart';
import '../../media_wizard_service/media_wizard_service.dart';
import '../models/action_control.dart';
import '../providers/show_controls.dart';
import 'media_background.dart';
import 'media_controls.dart';

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
      return MediaPreviewService(
        media: media,
        parentIdentifier: parentIdentifier,
        autoStart: autoStart,
        autoPlay: autoPlay,
        onLockPage: onLockPage,
        isLocked: isLocked,
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
    final ac = AccessControlExt.onGetMediaActionControl(media);
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
                              autoStart: autoStart,
                              autoPlay: autoPlay,
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
                                errorBuilder: (_, __) {
                                  throw UnimplementedError('errorBuilder');
                                  // ignore: dead_code
                                },
                                loadingBuilder: () {
                                  throw UnimplementedError('loadingBuilder');
                                  // ignore: dead_code
                                },
                                id: media.id!,
                                builder: (previewUri) {
                                  return ImageViewer.basic(
                                    uri: previewUri,
                                    autoStart: autoStart,
                                    autoPlay: autoPlay,
                                    onLockPage: onLockPage,
                                    isLocked: isLocked,
                                  );
                                },
                              ),
                              errorBuilder: BrokenImage.show,
                              loadingBuilder: GreyShimmer.show,
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
                    onMove: ac.onMove(
                      () => MediaWizardService.openWizard(
                        context,
                        ref,
                        CLSharedMedia(
                          entries: [media],
                          type: UniversalMediaSource.move,
                        ),
                      ),
                    ),
                    onDelete: ac.onDelete(() async {
                      final confirmed = await ConfirmAction.deleteMediaMultiple(
                            context,
                            ref,
                            media: [media],
                          ) ??
                          false;
                      if (!confirmed) return confirmed;
                      if (context.mounted) {
                        return theStore.mediaUpdater.delete(media.id!);
                      }
                      return false;
                    }),
                    onShare: ac.onShare(
                      () => theStore.mediaUpdater.share(context, [media]),
                    ),
                    onEdit: ac.onEdit(
                      () async {
                        final updatedMedia =
                            await PageManager.of(context, ref).openEditor(
                          media,
                          canDuplicateMedia: ac.canDuplicateMedia,
                        );
                        if (updatedMedia != media && context.mounted) {
                          // If id is same, refresh, and still
                          // global refresh may overwrite.
                          /* if (updatedMedia?.id == media.id) {
                            setState(() {
                              media = updatedMedia;
                            });
                          } */
                        }

                        return true;
                      },
                    ),
                    onPin: media.isMediaLocallyAvailable
                        ? ac.onPin(
                            () async {
                              final res =
                                  await theStore.mediaUpdater.pinToggleMultiple(
                                {media.id},
                                onGetPath: (media) {
                                  if (media.isMediaLocallyAvailable) {
                                    return theStore.directories
                                        .getMediaAbsolutePath(media);
                                  }

                                  return null;
                                },
                              );
                              if (res) {
                                /*  setState(() {}); */
                              }
                              return res;
                            },
                          )
                        : null,
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
