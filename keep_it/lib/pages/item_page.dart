import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/models/album_manager_helper.dart';
import 'package:share_plus/share_plus.dart';

import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/media_view/media_controls.dart';

class CollectionItemPage extends ConsumerWidget {
  const CollectionItemPage({
    required this.id,
    required this.collectionId,
    required this.parentIdentifier,
    super.key,
  });
  final int collectionId;
  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMediaByCollectionId(
      collectionId: collectionId,
      buildOnData: (items) {
        if (items.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.canPop()) {
              context.pop();
            }
          });
          return const EmptyState(message: 'No Media');
        }
        final initialMedia = items.where((e) => e.id == id).firstOrNull;
        final initialMediaIndex =
            initialMedia == null ? 0 : items.indexOf(initialMedia);

        return MediaInPageView(
          media: items,
          parentIdentifier: parentIdentifier,
          initialMediaIndex: initialMediaIndex,
        );
      },
    );
  }
}

class MediaInPageView extends ConsumerStatefulWidget {
  const MediaInPageView({
    required this.initialMediaIndex,
    required this.media,
    required this.parentIdentifier,
    super.key,
  });
  final List<CLMedia> media;
  final int initialMediaIndex;
  final String parentIdentifier;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => MediaInPageViewState();
}

class MediaInPageViewState extends ConsumerState<MediaInPageView> {
  bool lockPage = false;
  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final showControl = ref.watch(showControlsProvider);
    if (!showControl.showStatusBar) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }

    return FullscreenLayout(
      useSafeArea: false,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (!lockPage) {
            ref.read(showControlsProvider.notifier).toggleControls();
          }
        },
        child: Stack(
          children: [
            const MediaBackground(),
            LayoutBuilder(
              builder: (context, boxConstraints) {
                return SizedBox(
                  width: boxConstraints.maxWidth,
                  height: boxConstraints.maxHeight,
                  child: ItemView(
                    items: widget.media,
                    startIndex: widget.initialMediaIndex,
                    parentIdentifier: widget.parentIdentifier,
                    isLocked: lockPage,
                    onLockPage: ({required bool lock}) {
                      setState(() {
                        lockPage = lock;
                        if (lock) {
                          ref
                              .read(showControlsProvider.notifier)
                              .hideControls();
                        } else {
                          ref
                              .read(showControlsProvider.notifier)
                              .showControls();
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CircledIcon extends ConsumerWidget {
  const CircledIcon(this.iconData, {super.key, this.onTap});
  final IconData iconData;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CLTheme.of(context)
              .colors
              .iconBackgroundTransparent, // Color for the circular container
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: CLButtonIcon.verySmall(
            iconData,
            color: CLTheme.of(context).colors.iconColorTransparent,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class MediaBackground extends ConsumerWidget {
  const MediaBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);

    return AnimatedOpacity(
      opacity: showControl.showBackground ? 0 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.inverseSurface),
      ),
    );
  }
}

class ItemView extends ConsumerStatefulWidget {
  const ItemView({
    required this.items,
    required this.startIndex,
    required this.parentIdentifier,
    required this.isLocked,
    this.onLockPage,
    super.key,
  });
  final List<CLMedia> items;
  final String parentIdentifier;
  final int startIndex;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;

  @override
  ConsumerState<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends ConsumerState<ItemView> {
  late final PageController _pageController;
  late int currIndex;

  @override
  void initState() {
    currIndex = widget.startIndex;
    _pageController = PageController(initialPage: widget.startIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.items[currIndex];
    return Stack(
      children: [
        Positioned.fill(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            physics:
                widget.isLocked ? const NeverScrollableScrollPhysics() : null,
            onPageChanged: (index) {
              setState(() {
                currIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final media = widget.items[index];

              return Hero(
                tag: '${widget.parentIdentifier} /item/${media.id}',
                child: MediaViewer(
                  media: media,
                  autoStart: currIndex == index,
                  onLockPage: widget.onLockPage,
                ),
              );
            },
          ),
        ),
        GetDBManager(
          builder: (dbManager) {
            return MediaControls(
              onMove: () async {
                unawaited(
                  context.push(
                    '/move?ids=${media.id}',
                  ),
                );
                return true;
              },
              onDelete: () async =>
                  await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return CLConfirmAction(
                        title: 'Confirm delete',
                        message: 'Are you sure you want to delete '
                            'this ${media.type.name}?',
                        child: PreviewService(media: media),
                        onConfirm: ({required confirmed}) async {
                          await dbManager.deleteMedia(
                            media,
                            onDeleteFile: (f) async => f.deleteIfExists(),
                            onRemovePin: (id) async => AlbumManagerHelper()
                                .removeMedia(context, ref, id),
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop(confirmed);
                          }
                        },
                      );
                    },
                  ) ??
                  false,
              onShare: () async {
                final box = context.findRenderObject() as RenderBox?;
                final files = [XFile(media.path)];
                final shareResult = await Share.shareXFiles(
                  files,
                  // text: 'Share from KeepIT',
                  subject: 'Exporting media from KeepIt',
                  sharePositionOrigin:
                      box!.localToGlobal(Offset.zero) & box.size,
                );
                return switch (shareResult.status) {
                  ShareResultStatus.dismissed => false,
                  ShareResultStatus.unavailable => false,
                  ShareResultStatus.success => true,
                };
              },
              onEdit: (media.pin != null)
                  ? () async {
                      await ref.read(notificationMessageProvider.notifier).push(
                            "Unpin to edit.\n Pinned items can't be edited",
                          );
                      return true;
                    }
                  : () async {
                      unawaited(
                        context.push(
                          '/mediaEditor?id=${media.id}',
                        ),
                      );
                      return true;
                    },
              onPin: () async {
                await dbManager.togglePin(
                  media,
                  onPin: AlbumManagerHelper().albumManager.addMedia,
                  onRemovePin: (id) async =>
                      AlbumManagerHelper().removeMedia(context, ref, id),
                );
                return true;
              },
              media: widget.items[currIndex],
            );
          },
        ),
      ],
    );
  }
}
