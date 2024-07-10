import 'package:colan_services/services/shared_media_service/models/on_get_media.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/action_control.dart';
import 'media_controls.dart';
import 'media_viewer.dart';

class MediaPageView extends ConsumerStatefulWidget {
  const MediaPageView({
    required this.items,
    required this.startIndex,
    required this.actionControl,
    required this.parentIdentifier,
    required this.isLocked,
    this.onLockPage,
    super.key,
  });
  final List<CLMedia> items;
  final String parentIdentifier;
  final ActionControl actionControl;
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
    final ac = widget.actionControl;
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
                child: MediaViewerRaw(
                  media: media,
                  autoStart: currIndex == index,
                  onLockPage: widget.onLockPage,
                  isLocked: widget.isLocked,
                ),
              );
            },
          ),
        ),
        MediaHandlerWidget(
          builder: ({required action}) {
            return MediaControls(
              onMove: ac.onMove(() => action.move([media])),
              onDelete: ac.onDelete(() => action.delete([media])),
              onShare: ac.onShare(() => action.share([media])),
              onEdit: ac.onEdit(() => action.edit([media])),
              onPin: ac.onPin(() => action.togglePin([media])),
              media: media,
            );
          },
        ),
      ],
    );
  }
}
