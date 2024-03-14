import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:store/store.dart';

class ItemPage extends ConsumerWidget {
  const ItemPage({required this.id, required this.collectionId, super.key});
  final int collectionId;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      child: GetMediaByCollectionId(
        collectionId: collectionId,
        buildOnData: (List<CLMedia> items) {
          final media = items.where((e) => e.id == id).first;
          final index = items.indexOf(media);
          return Stack(
            children: [
              const MediaBackground(),
              LayoutBuilder(
                builder: (context, boxConstraints) {
                  return SizedBox(
                    width: boxConstraints.maxWidth,
                    height: boxConstraints.maxHeight,
                    child: ItemView(
                      items: items,
                      startIndex: index,
                    ),
                  );
                },
              ),
              const Positioned(
                top: 8,
                right: 8,
                child: ShowControl(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ShowControl extends ConsumerWidget {
  const ShowControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);

    if (showControl.showControl) {
      return const PopFullScreen();
    } else {
      return const IgnorePointer();
    }
  }
}

class MediaBackground extends ConsumerWidget {
  const MediaBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);
    return Container(
      decoration:
          BoxDecoration(color: showControl.showControl ? null : Colors.blue),
    );
  }
}

class ItemView extends StatefulWidget {
  const ItemView({required this.items, required this.startIndex, super.key});
  final List<CLMedia> items;
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
      itemCount: widget.items.length,
      onPageChanged: (index) {
        setState(() {
          currIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final media = widget.items[index];
        final formattedDate = media.originalDate == null
            ? 'No date'
            : DateFormat('dd MMMM yyyy').format(media.originalDate!);

        return Hero(
          tag: '/item/${media.collectionId}/${media.id}',
          child: switch (media.type) {
            CLMediaType.image => ImageViewerBasic(file: File(media.path)),
            CLMediaType.video => Center(
                child: VideoPlayer(
                  media: media,
                  alternate: CLMediaPreview(
                    media: media,
                  ),
                  isSelected: currIndex == index,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.centerLeft,
                      child: CLText.large(
                        formattedDate,
                        textAlign: TextAlign.start,
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withAlpha(192),
                      ),
                    ),
                  ],
                ),
              ),
            _ => throw UnimplementedError('Not yet implemented')
          },
        );
      },
    );
  }
}
