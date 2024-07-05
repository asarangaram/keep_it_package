import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../shared_media_service/models/media_handler.dart';
import '../video_player_service/providers/show_controls.dart';
import 'models/action_control.dart';
import 'widgets/media_background.dart';
import 'widgets/media_controls.dart';
import 'widgets/media_viewer.dart';

class MediaViewService extends ConsumerStatefulWidget {
  factory MediaViewService({
    required CLMedia media,
    required String parentIdentifier,
    ActionControl? actionControl,
    Key? key,
  }) {
    return MediaViewService._(
      initialMediaIndex: 0,
      media: [media],
      parentIdentifier: parentIdentifier,
      actionControl: actionControl ?? ActionControl.full(),
      key: key,
    );
  }
  factory MediaViewService.pageView({
    required int initialMediaIndex,
    required List<CLMedia> media,
    required String parentIdentifier,
    ActionControl? actionControl,
    Key? key,
  }) {
    return MediaViewService._(
      initialMediaIndex: initialMediaIndex,
      media: media,
      parentIdentifier: parentIdentifier,
      actionControl: actionControl ?? ActionControl.full(),
      key: key,
    );
  }
  const MediaViewService._({
    required this.initialMediaIndex,
    required this.media,
    required this.parentIdentifier,
    required this.actionControl,
    super.key,
  });

  final List<CLMedia> media;
  final int initialMediaIndex;
  final String parentIdentifier;
  final ActionControl actionControl;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => MediaInPageViewState();
}

class MediaInPageViewState extends ConsumerState<MediaViewService> {
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

    return GestureDetector(
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
                child: MediaPageView(
                  items: widget.media,
                  startIndex: widget.initialMediaIndex,
                  parentIdentifier: widget.parentIdentifier,
                  isLocked: lockPage,
                  onLockPage: ({required bool lock}) {
                    setState(() {
                      lockPage = lock;
                      if (lock) {
                        ref.read(showControlsProvider.notifier).hideControls();
                      } else {
                        ref.read(showControlsProvider.notifier).showControls();
                      }
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MediaPageView extends ConsumerStatefulWidget {
  const MediaPageView({
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
  ConsumerState<MediaPageView> createState() => _ItemViewState();
}

class _ItemViewState extends ConsumerState<MediaPageView> {
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
            final mediaHandler =
                MediaHandler(media: media, dbManager: dbManager);
            return MediaControls(
              onMove: () => mediaHandler.move(context, ref),
              onDelete: () => mediaHandler.delete(context, ref),
              onShare: () => mediaHandler.share(context, ref),
              onEdit: () => mediaHandler.edit(context, ref),
              onPin: () => mediaHandler.togglePin(context, ref),
              media: widget.items[currIndex],
            );
          },
        ),
      ],
    );
  }
}
