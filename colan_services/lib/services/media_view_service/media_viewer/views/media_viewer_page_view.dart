import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/services/media_view_service/media_viewer/views/media_viewer_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/ui_state.dart' show uiStateManager;

class MediaViewerPageView extends ConsumerStatefulWidget {
  const MediaViewerPageView({
    required this.parentIdentifier,
    required this.playerControls,
    super.key,
  });
  final String parentIdentifier;
  final VideoPlayerControls playerControls;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MediaViewerPageViewState();
}

class _MediaViewerPageViewState extends ConsumerState<MediaViewerPageView> {
  late final PageController pageController;

  @override
  void initState() {
    pageController = PageController(
      initialPage: uiStateManager.notifier.state.currentIndex,
    );

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateManagerNotifier = uiStateManager.notifier;

    return ListenableBuilder(
      listenable: stateManagerNotifier,
      builder: (_, __) {
        final stateManager = stateManagerNotifier.state;
        return PageView.builder(
          controller: pageController,
          itemCount: stateManager.entities.length,
          onPageChanged: (index) {
            stateManagerNotifier.currIndex = index;
          },
          itemBuilder: (context, index) {
            return ViewMedia(
              parentIdentifier: widget.parentIdentifier,
              currentItem: stateManager.entities[index],
              autoStart: index == stateManagerNotifier.state.currentIndex,
              playerControls: widget.playerControls,
            );
          },
        );
      },
    );
  }
}
