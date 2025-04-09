import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'media_view.dart';

class MediaPageView extends ConsumerStatefulWidget {
  const MediaPageView({
    required this.items,
    required this.startIndex,
    required this.parentIdentifier,
    required this.isLocked,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.onLockPage,
    super.key,
  });
  final List<StoreEntity> items;

  final String parentIdentifier;

  final int startIndex;
  final bool isLocked;
  final void Function({required bool lock})? onLockPage;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
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
        PageManager.of(context).pop();
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
                errorBuilder: widget.errorBuilder,
                loadingBuilder: widget.loadingBuilder,
              ),
            ),
          ],
        );
      },
    );
  }
}
