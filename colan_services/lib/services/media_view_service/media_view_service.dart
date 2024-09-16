import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../notes_service/notes_service.dart';

import 'providers/show_controls.dart';
import 'widgets/media_page_view.dart';
import 'widgets/media_view.dart';

class MediaViewService extends StatelessWidget {
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
      isPreview: false,
    );
  }
  factory MediaViewService.preview(
    CLMedia media, {
    required String parentIdentifier,
    Key? key,
  }) {
    return MediaViewService._(
      initialMediaIndex: 0,
      media: [media],
      parentIdentifier: parentIdentifier,
      actionControl: ActionControl.none(),
      key: key,
      isPreview: true,
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
      isPreview: false,
    );
  }
  const MediaViewService._({
    required this.initialMediaIndex,
    required this.media,
    required this.parentIdentifier,
    required this.actionControl,
    required this.isPreview,
    super.key,
  });

  final List<CLMedia> media;
  final int initialMediaIndex;
  final String parentIdentifier;
  final bool isPreview;
  final ActionControl actionControl;

  @override
  Widget build(BuildContext context) {
    if (isPreview) {
      return Column(
        children: [
          Expanded(
            child: CLAspectRationDecorated(
              //hasBorder: true,
              //borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: MediaView.preview(
                media[0],
                parentIdentifier: parentIdentifier,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: CLLabel.tiny(media[0].name),
          ),
        ],
      );
    }
    if (media.length == 1) {
      return MediaViewService0._(
        initialMediaIndex: 0,
        media: media,
        parentIdentifier: parentIdentifier,
        actionControl: actionControl,
        key: key,
      );
    }

    return MediaViewService0._(
      initialMediaIndex: initialMediaIndex,
      media: media,
      parentIdentifier: parentIdentifier,
      actionControl: actionControl,
      key: key,
    );
  }
}

class MediaViewService0 extends ConsumerStatefulWidget {
  const MediaViewService0._({
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
                  actionControl: widget.actionControl,
                  autoStart: true,
                  autoPlay: true,
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
