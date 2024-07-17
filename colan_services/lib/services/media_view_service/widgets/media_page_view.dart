import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_controls.dart';
import 'media_viewer.dart';

class MediaPageView extends ConsumerStatefulWidget {
  const MediaPageView({
    required this.items,
    required this.startIndex,
    required this.actionControl,
    required this.parentIdentifier,
    required this.isLocked,
    required this.buildNotes,
    required this.getPreview,
    required this.canDuplicateMedia,
    this.onLockPage,
    super.key,
  });
  final List<CLMedia> items;
  final String parentIdentifier;

  final ActionControl actionControl;
  final int startIndex;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final Widget Function(CLMedia media) buildNotes;
  final Widget Function(CLMedia media) getPreview;
  final bool canDuplicateMedia;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (currIndex >= widget.items.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CLPopScreen.onPop(context);
      });
      return BasicPageService.withNavBar(message: 'Media seems deleted');
    }
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
                  buildNotes: currIndex == index
                      ? widget.buildNotes
                      : (_) {
                          return Container();
                        },
                  getPreview: widget.getPreview,
                ),
              );
            },
          ),
        ),
        MediaControls(
          onMove: ac.onMove(
            () => TheStore.of(context)
                .openWizard([media], UniversalMediaSource.move),
          ),
          onDelete: ac.onDelete(() async {
            final res = await TheStore.of(context).deleteMediaMultiple([media]);
            if (res) {
              currIndex = widget.startIndex;
              setState(() {});
            }
            return null;
          }),
          onShare: ac
              .onShare(() => TheStore.of(context).shareMediaMultiple([media])),
          onEdit: (media.type == CLMediaType.video &&
                  !VideoEditServices.isSupported)
              ? null
              : ac.onEdit(
                  () => TheStore.of(context).openEditor(
                    [media],
                    canDuplicateMedia: ac.canDuplicateMedia,
                  ),
                ),
          onPin:
              ac.onPin(() => TheStore.of(context).togglePinMultiple([media])),
          media: media,
        ),
      ],
    );
  }
}
