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
          return Column(
            children: [
              Flexible(
                flex: 2,
                child: Align(
                  child: InfiniteCarousel.builder(
                      itemCount: items.entries.length,
                      itemExtent: MediaQuery.of(context).size.width,
                      center: false,
                      anchor: 0.0,
                      velocityFactor: 1,
                      onIndexChanged: (index) {},
                      axisDirection: Axis.horizontal,
                      loop: false,
                      itemBuilder: (context, itemIndex, realIndex) {
                        return Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(1.0),
                          child: LoadMedia(
                            mediaInfo: CLMediaImage(
                              path: items.entries[realIndex].path,
                              type: items.entries[realIndex].type,
                            ),
                            onMediaLoaded: (mediaData) {
                              return switch (mediaData) {
                                (CLMediaImage image)
                                    when mediaData.runtimeType ==
                                        CLMediaImage =>
                                  CLImageViewer(
                                    image: image.data!,
                                    allowZoom: false,
                                  ),
                                (CLMediaVideo video)
                                    when mediaData.runtimeType ==
                                        CLMediaVideo =>
                                  VideoPlayerScreen(
                                    path: video.path,
                                    aspectRatio: mediaData.aspectRatio,
                                  ),
                                _ => throw UnimplementedError(
                                    "Not yet implemented")
                              };
                            },
                          ),
                        );
                      }),
                ),
              ),
              Flexible(
                  child: TextField(
                maxLines: 100,
                decoration: const InputDecoration(
                    labelText: 'About',
                    helperText: "Tab on the text to edit",
                    enabled: false, // Disable editing
                    suffixIcon: CLIcon.standard(Icons.edit_outlined)),
                controller:
                    TextEditingController(text: items.cluster.description),
                onTap: () {
                  print('TextField tapped');
                },
                onChanged: (value) {
                  print('Value changed: $value');
                }, // Set initial text
              ))
            ],
          );
        });
  }
}
