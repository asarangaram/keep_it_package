import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:store/store.dart';

import '../widgets/pop_fullscreen.dart';

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
      buildOnData: (media) {
        final initialMedia = media.where((e) => e.id == id).first;
        final initialMediaIndex = media.indexOf(initialMedia);
        return MediaInPageView(
          media: media,
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
    if (!showControl) {
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
            SafeArea(
              bottom: !lockPage,
              top: !lockPage,
              child: Stack(
                children: [
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
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: ShowControl(),
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

class ShowControl extends ConsumerWidget {
  const ShowControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);

    if (showControl) {
      return const PopFullScreen();
    } else {
      return const IgnorePointer();
    }
  }
}

class MediaBackground extends ConsumerWidget {
  const MediaBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);

    return AnimatedOpacity(
      opacity: showControl ? 0 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.inverseSurface),
      ),
    );
  }
}

class ItemView extends StatefulWidget {
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
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
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
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.items.length,
      physics: widget.isLocked ? const NeverScrollableScrollPhysics() : null,
      onPageChanged: (index) {
        setState(() {
          currIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final media = widget.items[index];
        final formattedDate = media.originalDate == null
            ? 'Err: No date'
            : DateFormat('dd MMMM yyyy').format(media.originalDate!);

        return Hero(
          tag: '${widget.parentIdentifier} /item/${media.id}',
          child: switch (media.type) {
            CLMediaType.image => CLzImage(
                file: File(media.path),
                onLockPage: widget.onLockPage,
                onEdit: media.id == null
                    ? null
                    : () {
                        context.push('/mediaEditor?id=${media.id}');
                      },
              ),
            CLMediaType.video => Center(
                child: VideoPlayer(
                  media: media,
                  alternate: PreviewService(
                    media: media,
                  ),
                  isSelected: currIndex == index,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.centerLeft,
                      child: CLText.standard(
                        formattedDate,
                        textAlign: TextAlign.start,
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withAlpha(192),
                      ),
                    ),
                  ],
                ),
              ),
            _ => throw UnimplementedError('Not yet implemented')
          },
        );
      },
    );
  }
}
