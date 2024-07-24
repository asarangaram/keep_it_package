import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notes_service/notes_service.dart';
import '../store_service/widgets/w3_get_note.dart';
import '../video_player_service/providers/show_controls.dart';

import 'widgets/media_page_view.dart';
import 'widgets/media_view.dart';

class MediaViewService extends ConsumerStatefulWidget {
  factory MediaViewService({
    required CLMedia media,
    required String parentIdentifier,
    required Widget Function(CLMedia media) getPreview,
    ActionControl? actionControl,
    Key? key,
  }) {
    return MediaViewService._(
      initialMediaIndex: 0,
      media: [media],
      parentIdentifier: parentIdentifier,
      actionControl: actionControl ?? ActionControl.full(),
      key: key,
      getPreview: getPreview,
    );
  }
  factory MediaViewService.pageView({
    required int initialMediaIndex,
    required List<CLMedia> media,
    required String parentIdentifier,
    required Widget Function(CLMedia media) getPreview,
    ActionControl? actionControl,
    Key? key,
  }) {
    return MediaViewService._(
      initialMediaIndex: initialMediaIndex,
      media: media,
      parentIdentifier: parentIdentifier,
      actionControl: actionControl ?? ActionControl.full(),
      key: key,
      getPreview: getPreview,
    );
  }
  const MediaViewService._({
    required this.initialMediaIndex,
    required this.media,
    required this.parentIdentifier,
    required this.actionControl,
    required this.getPreview,
    super.key,
  });

  final List<CLMedia> media;
  final int initialMediaIndex;
  final String parentIdentifier;

  final ActionControl actionControl;

  final Widget Function(CLMedia media) getPreview;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      MediaViewServiceState();
}

class MediaViewServiceState extends ConsumerState<MediaViewService> {
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
                  getPreview: widget.getPreview,
                  parentIdentifier: widget.parentIdentifier,
                  isLocked: lockPage,
                  onLockPage: onLockPage,
                  actionControl: widget.actionControl,
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
                  child: NotesService(
                    media: widget.media[0],
                  ),
                ),
            ],
          )
        : MediaPageView(
            items: widget.media,
            getPreview: widget.getPreview,
            startIndex: widget.initialMediaIndex,
            actionControl: widget.actionControl,
            parentIdentifier: widget.parentIdentifier,
            isLocked: lockPage,
            canDuplicateMedia: widget.actionControl.canDuplicateMedia,
            onLockPage: onLockPage,
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
