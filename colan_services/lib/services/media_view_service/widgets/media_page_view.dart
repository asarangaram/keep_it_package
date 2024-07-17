import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_view.dart';

class MediaPageView extends ConsumerStatefulWidget {
  const MediaPageView({
    required this.items,
    required this.startIndex,
    required this.actionControl,
    required this.parentIdentifier,
    required this.isLocked,
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

  final Widget Function(CLMedia media) getPreview;
  final bool canDuplicateMedia;
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
        CLPopScreen.onPop(context);
      });
      return BasicPageService.withNavBar(message: 'Media seems deleted');
    }

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
        print('itemBuilder getting called from MediaPageViewState');
        return MediaView(
          media: media,
          notes: const [],
          parentIdentifier: widget.parentIdentifier,
          actionControl: widget.actionControl,
          autoStart: currIndex == index,
          onLockPage: widget.onLockPage,
          isLocked: widget.isLocked,
          getPreview: widget.getPreview,
        );
      },
    );
  }
}
