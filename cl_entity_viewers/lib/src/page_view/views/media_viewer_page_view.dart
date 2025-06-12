import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video_player_controls.dart';
import '../providers/ui_state.dart' show mediaViewerUIStateProvider;
import 'media_viewer_core.dart' show ViewMedia;

class MediaViewerPageView extends ConsumerStatefulWidget {
  const MediaViewerPageView({
    required this.playerControls,
    super.key,
  });

  final VideoPlayerControls playerControls;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MediaViewerPageViewState();
}

class _MediaViewerPageViewState extends ConsumerState<MediaViewerPageView> {
  late final PageController pageController;

  @override
  void initState() {
    final currentIndex =
        ref.read(mediaViewerUIStateProvider.select((e) => e.currentIndex));
    pageController = PageController(initialPage: currentIndex);

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(mediaViewerUIStateProvider);

    return PageView.builder(
      physics: s.showMenu ? null : NeverScrollableScrollPhysics(),
      controller: pageController,
      itemCount: s.entities.length,
      onPageChanged: (index) {
        ref.read(mediaViewerUIStateProvider.notifier).currIndex = index;
      },
      itemBuilder: (context, index) {
        return ViewMedia(
          currentItem: s.entities[index],
          autoStart: index == s.currentIndex,
          playerControls: widget.playerControls,
        );
      },
    );
  }
}
