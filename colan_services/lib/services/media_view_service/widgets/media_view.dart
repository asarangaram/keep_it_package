import 'dart:math' as math;

import 'package:animated_icon/animated_icon.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:media_viewers/media_viewers.dart';
import 'package:store/store.dart';

import '../../basic_page_service/dialogs.dart';
import '../../basic_page_service/navigators.dart';

import '../../incoming_media_service/models/cl_shared_media.dart';
import '../../media_wizard_service/media_wizard_service.dart';
import '../providers/show_controls.dart';
import 'media_background.dart';
import 'media_controls.dart';

class MediaView extends StatelessWidget {
  factory MediaView({
    required CLMedia media,
    required String parentIdentifier,
    required ActionControl Function(CLMedia media) onGetMediaActionControl,
    required bool autoStart,
    required bool autoPlay,
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
      onGetMediaActionControl: onGetMediaActionControl,
      onLockPage: onLockPage,
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
      onGetMediaActionControl: (_) => ActionControl.none(),
    );
  }
  const MediaView._({
    required this.isPreview,
    required this.media,
    required this.parentIdentifier,
    required this.isLocked,
    required this.onGetMediaActionControl,
    required this.autoStart,
    required this.autoPlay,
    this.onLockPage,
    super.key,
  });
  final CLMedia media;

  final String parentIdentifier;

  final ActionControl Function(CLMedia media) onGetMediaActionControl;
  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    /* log(
      '${media.md5String}  isPreview: $isPreview',
      name: 'MediaView | build',
    ); */

    if (isPreview) {
      return GetStoreUpdater(
        builder: (theStore) {
          return GetPreviewUri(
            id: media.id!,
            builder: (previewUri) {
              /* log(
                'preview URI: $previewUri',
                name: 'MediaView | build',
              ); */
              return Hero(
                tag: '$parentIdentifier /item/${media.id}',
                child: ImageViewer.basic(
                  uri: previewUri,
                  autoStart: autoStart,
                  autoPlay: autoPlay,
                  onLockPage: onLockPage,
                  isLocked: isLocked,
                  errorBuilder: BrokenImage.show,
                  loadingBuilder: GreyShimmer.show,
                  fit: BoxFit.cover,
                  overlays: [
                    if (media.pin != null)
                      OverlayWidgets(
                        alignment: Alignment.bottomRight,
                        child: FutureBuilder(
                          future: theStore.albumManager.isPinBroken(media.pin),
                          builder: (context, snapshot) {
                            return Transform.rotate(
                              angle: math.pi / 4,
                              child: CLIcon.veryLarge(
                                snapshot.data ?? false
                                    ? clIcons.brokenPin
                                    : clIcons.pinned,
                                color: snapshot.data ?? false
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
                    if (media.type == CLMediaType.video)
                      OverlayWidgets(
                        alignment: Alignment.center,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(
                                  192,
                                ), // Color for the circular container
                          ),
                          child: CLIcon.veryLarge(
                            clIcons.playerPlay,
                            color:
                                CLTheme.of(context).colors.iconColorTransparent,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return MediaView0(
      media: media,
      parentIdentifier: parentIdentifier,
      isLocked: isLocked,
      onGetMediaActionControl: onGetMediaActionControl,
      autoPlay: autoPlay,
      autoStart: autoStart,
      onLockPage: onLockPage,
    );
  }
}

class MediaIsDownloading extends StatelessWidget {
  const MediaIsDownloading({
    required this.icon,
    super.key,
    this.color = Colors.black,
  });

  final AnimateIcons icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimateIcon(
      key: UniqueKey(),
      onTap: () {},
      iconType: IconType.continueAnimation,
      color: color,
      animateIcon: icon,
      //animateIcon: AnimateIcons.download,
    );
  }
}

class MediaView0 extends ConsumerWidget {
  const MediaView0({
    required this.media,
    required this.parentIdentifier,
    required this.isLocked,
    required this.onGetMediaActionControl,
    required this.autoStart,
    required this.autoPlay,
    this.onLockPage,
    super.key,
  });
  final CLMedia media;

  final String parentIdentifier;

  final ActionControl Function(CLMedia media) onGetMediaActionControl;
  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ac = onGetMediaActionControl(media);
    final showControl = ref.watch(showControlsProvider);
    return GetStoreUpdater(
      builder: (theStore) {
        return GetMediaUri(
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
                              errorBuilder: BrokenImage.show,
                              loadingBuilder: GreyShimmer.show,
                            ),
                          CLMediaType.video => VideoPlayer(
                              uri: mediaUri!,
                              autoStart: autoStart,
                              autoPlay: autoPlay,
                              onLockPage: onLockPage,
                              isLocked: isLocked,
                              placeHolder: GetPreviewUri(
                                id: media.id!,
                                builder: (previewUri) {
                                  return ImageViewer.basic(
                                    uri: previewUri,
                                    autoStart: autoStart,
                                    autoPlay: autoPlay,
                                    onLockPage: onLockPage,
                                    isLocked: isLocked,
                                    errorBuilder: BrokenImage.show,
                                    loadingBuilder: GreyShimmer.show,
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
                        final updatedMedia = await Navigators.openEditor(
                          context,
                          ref,
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
                    onPin: ac.onPin(
                      () async {
                        final res =
                            await theStore.mediaUpdater.pinToggle(media.id!);
                        if (res) {
                          /*  setState(() {}); */
                        }
                        return res;
                      },
                    ),
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
