import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/show_controls.dart';
import 'media_view.dart';

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
  ConsumerState<MediaPageView> createState() => MediaPageViewState();
}

class MediaPageViewState extends ConsumerState<MediaPageView> {
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
        PageManager.of(context, ref).pop();
      });
      return BasicPageService.withNavBar(message: 'Media seems deleted');
    }
    final showControl = ref.watch(showControlsProvider);
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.items.length,
      physics: widget.isLocked ? const NeverScrollableScrollPhysics() : null,
      onPageChanged: (index) {
        setState(() {
          currIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final media = widget.items[index];
        return Column(
          children: [
            Expanded(
              child: MediaView(
                media: media,
                parentIdentifier: widget.parentIdentifier,
                autoStart: currIndex == index,
                autoPlay: currIndex == index,
                onLockPage: widget.onLockPage,
                isLocked: widget.isLocked,
              ),
            ),
            if (showControl.showNotes && !widget.isLocked)
              GestureDetector(
                onVerticalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity == null) return;
                  // pop on Swipe
                  if (details.primaryVelocity! > 0) {
                    ref.read(showControlsProvider.notifier).hideNotes();
                  }
                },
                child: NotesService(
                  media: media,
                ),
              ),
          ],
        );
      },
    );
  }
}
