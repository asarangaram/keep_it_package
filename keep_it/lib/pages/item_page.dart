import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/from_store/load_items.dart';

class ItemPage extends ConsumerWidget {
  const ItemPage({required this.id, required this.collectionId, super.key});
  final int collectionId;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadItems(
      collectionID: collectionId,
      buildOnData: (Items items) {
        final media = items.entries.where((e) => e.id == id).first;
        final index = items.entries.indexOf(media);
        return Stack(
          children: [
            ItemView(
              items: items,
              startIndex: index,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withAlpha(192), // Color for the circular container
                ),
                child: CLButtonIcon.small(
                  Icons.close,
                  color:
                      Theme.of(context).colorScheme.background.withAlpha(192),
                  onTap: context.canPop() ? context.pop : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ItemView extends StatefulWidget {
  const ItemView({required this.items, required this.startIndex, super.key});
  final Items items;
  final int startIndex;

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
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
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.items.entries.length,
      onPageChanged: (index) {
        setState(() {
          currIndex = index;
        });
      },
      itemBuilder: (context, index) {
        print('index is $index');
        final media = widget.items.entries[index];
        return Hero(
          tag: '/item/${media.collectionId}/${media.id}',
          child: SizedBox(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: switch (media.type) {
                  CLMediaType.image => ImageViewerBasic(file: File(media.path)),
                  CLMediaType.video => VideoPlayer(
                      media: media,
                      isSelected: currIndex == index,
                    ),
                  _ => throw UnimplementedError('Not yet implemented')
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
