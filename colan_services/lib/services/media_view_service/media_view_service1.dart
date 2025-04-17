import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../../providers/show_controls.dart';
import 'widgets/media_page_view.dart';
import 'widgets/media_view.dart';

class MediaViewService0 extends ConsumerStatefulWidget {
  const MediaViewService0({
    required this.initialMediaIndex,
    required this.media,
    required this.parentIdentifier,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final List<StoreEntity> media;
  final int initialMediaIndex;
  final String parentIdentifier;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      MediaViewService0State();
}

class MediaViewService0State extends ConsumerState<MediaViewService0> {
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

    return (widget.media.length == 1)
        ? Column(
            children: [
              Expanded(
                child: MediaView(
                  media: widget.media[0],
                  parentIdentifier: widget.parentIdentifier,
                  isLocked: lockPage,
                  onLockPage: onLockPage,
                  autoStart: true,
                  autoPlay: true,
                  errorBuilder: widget.errorBuilder,
                  loadingBuilder: widget.loadingBuilder,
                ),
              ),
              if (showControl.showNotes && !lockPage)
                GestureDetector(
                  onVerticalDragEnd: (DragEndDetails details) {
                    if (details.primaryVelocity == null) return;
                    // pop on Swipe
                    if (details.primaryVelocity! > 0) {
                      ref.read(showControlsProvider.notifier).hideNotes();
                    }
                  },
                ),
            ],
          )
        : MediaPageView(
            items: widget.media,
            startIndex: widget.initialMediaIndex,
            parentIdentifier: widget.parentIdentifier,
            isLocked: lockPage,
            onLockPage: onLockPage,
            errorBuilder: widget.errorBuilder,
            loadingBuilder: widget.loadingBuilder,
          );
  }

  void onLockPage({required bool lock}) {
    setState(() {
      lockPage = lock;
      if (lock) {
        ref.read(showControlsProvider.notifier).hideControls();
      } else {
        ref.read(showControlsProvider.notifier).showControls();
      }
    });
  }
}
