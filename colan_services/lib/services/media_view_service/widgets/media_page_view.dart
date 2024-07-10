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
    required this.storeAction,
    required this.actionControl,
    required this.parentIdentifier,
    required this.isLocked,
    required this.buildNotes,
    required this.getPreview,
    this.onLockPage,
    super.key,
  });
  final List<CLMedia> items;
  final String parentIdentifier;
  final StoreActions storeAction;
  final ActionControl actionControl;
  final int startIndex;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final Widget Function(CLMedia media) buildNotes;
  final Widget Function(CLMedia media) getPreview;
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
                  buildNotes: widget.buildNotes,
                  getPreview: widget.getPreview,
                ),
              );
            },
          ),
        ),
        MediaControls(
          onMove: ac.onMove(() => widget.storeAction.move([media])),
          onDelete: ac.onDelete(
            () => widget.storeAction.delete([media], confirmed: null),
          ),
          onShare: ac.onShare(() => widget.storeAction.share([media])),
          onEdit: ac.onEdit(() => widget.storeAction.edit([media])),
          onPin: ac.onPin(() => widget.storeAction.togglePin([media])),
          media: media,
        ),
      ],
    );
  }
}
