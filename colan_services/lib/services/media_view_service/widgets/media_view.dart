import 'dart:math' as math;

import 'package:colan_services/colan_services.dart';
import 'package:colan_services/internal/widgets/broken_image.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:media_viewers/media_viewers.dart';
import 'package:store/store.dart';

import '../../../internal/widgets/shimmer.dart';

import '../../gallery_service/models/m5_gallery_pin.dart';
import '../providers/show_controls.dart';
import 'media_background.dart';
import 'media_controls.dart';

class MediaView extends StatelessWidget {
  factory MediaView({
    required CLMedia media,
    required String parentIdentifier,
    required ActionControl actionControl,
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
      actionControl: actionControl,
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
      actionControl: ActionControl.none(),
    );
  }
  const MediaView._({
    required this.isPreview,
    required this.media,
    required this.parentIdentifier,
    required this.isLocked,
    required this.actionControl,
    required this.autoStart,
    required this.autoPlay,
    this.onLockPage,
    super.key,
  });
  final CLMedia media;

  final String parentIdentifier;

  final ActionControl actionControl;
  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    if (isPreview) {
      return CLAspectRationDecorated(
        hasBorder: true,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: GetStoreManager(
          builder: (theStore) {
            final previewUri = theStore.getValidPreviewPath(media);

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
                        future: AlbumManager.isPinBroken(media.pin),
                        builder: (context, snapshot) {
                          return Transform.rotate(
                            angle: math.pi / 4,
                            child: CLIcon.veryLarge(
                              snapshot.data ?? false
                                  ? MdiIcons.pinOffOutline
                                  : MdiIcons.pin,
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
                          color:
                              Theme.of(context).colorScheme.onSurface.withAlpha(
                                    192,
                                  ), // Color for the circular container
                        ),
                        child: CLIcon.veryLarge(
                          Icons.play_arrow_sharp,
                          color:
                              CLTheme.of(context).colors.iconColorTransparent,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }
    return MediaView0(
      media: media,
      parentIdentifier: parentIdentifier,
      isLocked: isLocked,
      actionControl: actionControl,
      autoPlay: autoPlay,
      autoStart: autoStart,
      onLockPage: onLockPage,
    );
  }
}

class MediaView0 extends ConsumerStatefulWidget {
  const MediaView0({
    required this.media,
    required this.parentIdentifier,
    required this.isLocked,
    required this.actionControl,
    required this.autoStart,
    required this.autoPlay,
    this.onLockPage,
    super.key,
  });
  final CLMedia media;

  final String parentIdentifier;

  final ActionControl actionControl;
  final bool autoStart;
  final bool autoPlay;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;

  @override
  ConsumerState<MediaView0> createState() => _MediaView0State();
}

class _MediaView0State extends ConsumerState<MediaView0> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    final ac = widget.actionControl;
    final showControl = ref.watch(showControlsProvider);
    return GetStoreManager(
      builder: (theStore) {
        final mediaUri = theStore.getValidMediaPath(media);
        final previewUri = theStore.getValidPreviewPath(media);
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => ref.read(showControlsProvider.notifier).toggleControls(),
          child: Stack(
            children: [
              const MediaBackground(),
              Positioned.fill(
                child: Hero(
                  tag: '${widget.parentIdentifier} /item/${media.id}',
                  child: SafeArea(
                    top: showControl.showNotes,
                    bottom: showControl.showNotes,
                    left: showControl.showNotes,
                    right: showControl.showNotes,
                    child: switch (media.type) {
                      CLMediaType.image => ImageViewer.guesture(
                          uri: mediaUri,
                          autoStart: widget.autoStart,
                          autoPlay: widget.autoPlay,
                          onLockPage: widget.onLockPage,
                          isLocked: widget.isLocked,
                          errorBuilder: BrokenImage.show,
                          loadingBuilder: GreyShimmer.show,
                        ),
                      CLMediaType.video => VideoPlayer(
                          uri: mediaUri,
                          autoStart: widget.autoStart,
                          autoPlay: widget.autoPlay,
                          onLockPage: widget.onLockPage,
                          isLocked: widget.isLocked,
                          placeHolder: ImageViewer.basic(
                            uri: previewUri,
                            autoStart: widget.autoStart,
                            autoPlay: widget.autoPlay,
                            onLockPage: widget.onLockPage,
                            isLocked: widget.isLocked,
                            errorBuilder: BrokenImage.show,
                            loadingBuilder: GreyShimmer.show,
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
                  () => TheStore.of(context).openWizard(
                    context,
                    [media],
                    UniversalMediaSource.move,
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
                    return theStore.deleteMediaMultiple(
                      [media],
                    );
                  }
                  return false;
                }),
                onShare: ac.onShare(
                  () =>
                      TheStore.of(context).shareMediaMultiple(context, [media]),
                ),
                onEdit: ac.onEdit(
                  () async {
                    final updatedMedia = await TheStore.of(context).openEditor(
                      context,
                      media,
                      canDuplicateMedia: ac.canDuplicateMedia,
                    );
                    if (updatedMedia != media && context.mounted) {
                      setState(() {
                        //media = updatedMedia;
                      });
                    }

                    return true;
                  },
                ),
                onPin: ac.onPin(
                  () async {
                    final res = await theStore.togglePinMultiple([media]);
                    if (res) {
                      setState(() {});
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
  }
}
