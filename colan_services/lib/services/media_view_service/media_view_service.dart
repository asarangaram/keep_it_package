import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../video_player_service/providers/show_controls.dart';
import 'models/action_control.dart';
import 'widgets/media_background.dart';
import 'widgets/media_page_view.dart';
import 'widgets/media_view.dart';

class MediaViewService extends ConsumerStatefulWidget {
  factory MediaViewService({
    required CLMedia media,
    required String parentIdentifier,
    required Widget Function(CLMedia media) buildNotes,
    required Widget Function(CLMedia media) getPreview,
    ActionControl? actionControl,
    Key? key,
  }) {
    return MediaViewService._(
      initialMediaIndex: 0,
      media: [media],
      parentIdentifier: parentIdentifier,
      actionControl: actionControl ?? ActionControl.full(),
      buildNotes: buildNotes,
      key: key,
      getPreview: getPreview,
    );
  }
  factory MediaViewService.pageView({
    required int initialMediaIndex,
    required List<CLMedia> media,
    required String parentIdentifier,
    required Widget Function(CLMedia media) buildNotes,
    required Widget Function(CLMedia media) getPreview,
    ActionControl? actionControl,
    Key? key,
  }) {
    return MediaViewService._(
      initialMediaIndex: initialMediaIndex,
      media: media,
      parentIdentifier: parentIdentifier,
      actionControl: actionControl ?? ActionControl.full(),
      buildNotes: buildNotes,
      key: key,
      getPreview: getPreview,
    );
  }
  const MediaViewService._({
    required this.initialMediaIndex,
    required this.media,
    required this.parentIdentifier,
    required this.actionControl,
    required this.buildNotes,
    required this.getPreview,
    super.key,
  });

  final List<CLMedia> media;
  final int initialMediaIndex;
  final String parentIdentifier;
  final ActionControl actionControl;
  final Widget Function(CLMedia media) buildNotes;
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
                child: widget.media.length == 1
                    ? MediaView(
                        item: widget.media[0],
                        getPreview: widget.getPreview,
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
                        actionControl: widget.actionControl,
                        buildNotes: widget.buildNotes,
                      )
                    : MediaPageView(
                        items: widget.media,
                        getPreview: widget.getPreview,
                        startIndex: widget.initialMediaIndex,
                        actionControl: ActionControl.full(),
                        parentIdentifier: widget.parentIdentifier,
                        isLocked: lockPage,
                        buildNotes: widget.buildNotes,
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
    );
  }
}
