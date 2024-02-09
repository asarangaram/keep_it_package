import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ItemsView extends ConsumerStatefulWidget {
  const ItemsView({required this.media, super.key});
  final List<CLMedia> media;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ItemsViewState();
}

class ItemsViewState extends ConsumerState<ItemsView> {
  late final AutoScrollController scrollController;
  int? currentIndex;

  @override
  void initState() {
    scrollController = AutoScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentIndex != null) {
        scrollController.scrollToIndex(
          currentIndex!,
          preferPosition: AutoScrollPosition.begin,
        );
      }
    });
    return CLCustomGrid(
      itemCount: widget.media.length,
      crossAxisCount: 1,
      layers: 1,
      controller: scrollController,
      itemBuilder: (context, index, l) {
        final media = widget.media[index];
        return switch (media.type) {
          CLMediaType.video => Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .65,
              ),
              child: GestureDetector(
                onTap: () =>
                    context.push('/item/${media.collectionId}/${media.id}'),
                child: VideoPreview(
                  media: widget.media[index],
                  fit: BoxFit.contain,

                  //onTap: onTap,
                ),
              ),
            ),
          _ => CLMediaPreview(
              media: widget.media[index],
            )
        };
      },
    );
  }
}
