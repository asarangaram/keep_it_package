import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../notifier/ui_state.dart' show uiStateManager;

class MediaViewerCore extends StatelessWidget {
  const MediaViewerCore({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    final currentItem = uiStateManager.notifier.select(
      (state) => state.currentItem,
    );
    final length = uiStateManager.notifier.select(
      (state) => state.length,
    );

    return GetVideoPlayerControls(
      builder: (controls) {
        return ListenableBuilder(
          listenable: uiStateManager.notifier,
          builder: (_, __) {
            return switch (length.value) {
              0 => Container(),
              1 => ViewMedia(
                  currentItem: currentItem.value,
                  parentIdentifier: parentIdentifier,
                  autoStart: true,
                  playerControls: controls,
                ),
              _ => MediaViewerPageView(
                  parentIdentifier: parentIdentifier,
                  playerControls: controls,
                )
            };
          },
        );
      },
    );
  }
}

class ViewMedia extends StatefulWidget {
  const ViewMedia({
    required this.currentItem,
    required this.parentIdentifier,
    required this.playerControls,
    super.key,
    this.autoStart = false,
  });
  final String parentIdentifier;
  final ViewerEntityMixin currentItem;
  final VideoPlayerControls playerControls;
  final bool autoStart;

  @override
  State<ViewMedia> createState() => _ViewMediaState();
}

class _ViewMediaState extends State<ViewMedia> {
  @override
  void initState() {
    //setVideo();
    super.initState();
  }

  Future<void> setVideo() async {
    // This seems still required
    await widget.playerControls.setVideo(
      widget.currentItem.mediaUri!,
      forced: false,
      autoPlay: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('autoStart = ${widget.autoStart}');

    return ListenableBuilder(
      listenable: uiStateManager.notifier,
      builder: (_, __) {
        final stateManager = uiStateManager.notifier.state;
        final currentItem = stateManager.currentItem;
        final isPlayable = widget.autoStart &&
            widget.playerControls.uri != widget.currentItem.mediaUri &&
            widget.currentItem.mediaType == CLMediaType.video &&
            widget.currentItem.mediaUri != null;
        return GetVideoPlayerControls(
          builder: (controls) {
            return GestureDetector(
              onTap: () async {
                await setVideo();
                await controls.onPlayPause(
                  autoPlay: false,
                  forced: isPlayable,
                );
              },
              child: MediaViewer(
                heroTag: '${widget.parentIdentifier} /item/${currentItem.id}',
                uri: currentItem.mediaUri!,
                previewUri: currentItem.previewUri,
                mime: (currentItem as StoreEntity).data.mimeType!,
                onLockPage: ({required bool lock}) {},
                isLocked: false,
                autoStart: widget.autoStart,
                autoPlay: true, // Fixme
                errorBuilder: (_, __) => const BrokenImage(),
                loadingBuilder: () => const GreyShimmer(),
                keepAspectRatio: true,
                hasGesture: !stateManager.showMenu,
              ),
            );
          },
        );
      },
    );
  }
}

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
          physics: !stateManager.showMenu
              ? const NeverScrollableScrollPhysics()
              : null,
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
