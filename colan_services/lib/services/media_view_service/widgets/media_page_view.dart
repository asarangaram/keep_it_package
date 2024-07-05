import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../shared_media_service/models/media_handler.dart';
import 'media_controls.dart';
import 'media_viewer.dart';

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
                child: MediaViewerRaw(
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
