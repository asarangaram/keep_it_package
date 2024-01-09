import 'dart:ui' as ui;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:keep_it/pages/views/load_from_store/load_image.dart';
import 'package:store/store.dart';

import '../main/keep_it_main_view.dart';
import '../video_player.dart';

class ItemsView extends ConsumerWidget {
  const ItemsView({
    super.key,
    required this.items,
  });

  final Items items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeepItMainView(
        onPop: context.canPop()
            ? () {
                context.pop();
              }
            : null,
        pageBuilder: (context, quickMenuScopeKey) {
          return InfiniteCarousel.builder(
            itemCount: items.entries.length,
            itemExtent: MediaQuery.of(context).size.height / 2,
            center: true,
            anchor: 0.0,
            velocityFactor: 0.2,
            onIndexChanged: (index) {},
            axisDirection: Axis.vertical,
            loop: false,
            itemBuilder: (context, itemIndex, realIndex) {
              return switch (items.entries[realIndex].type) {
                CLMediaType.image => LoadMediaImage(
                    mediaInfo: CLMediaInfo(
                      path: items.entries[realIndex].path,
                      type: CLMediaType.image,
                    ),
                    onImageLoaded: (ui.Image mediaData) => CLImageViewer(
                      image: mediaData,
                      allowZoom: false,
                    ),
                  ),
                CLMediaType.video => VideoPlayerScreen(
                    path: items.entries[realIndex].path,
                  ),
                _ => throw UnimplementedError("Not yet implemented")
              };
            },
          );
        });
  }
}
