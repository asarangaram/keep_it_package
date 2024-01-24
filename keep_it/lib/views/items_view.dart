import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/keep_it_main_view.dart';

import '../widgets/load_from_store.dart';

class ItemsView extends ConsumerWidget {
  const ItemsView({required this.clusterID, super.key});

  final int clusterID;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLFullscreenBox(
      child: CLBackground(
        child: LoadItems(
          clusterID: clusterID,
          buildOnData: (Items items, {required String docDir}) {
            return _ItemsView(items: items);
          },
        ),
      ),
    );
  }
}

class _ItemsView extends ConsumerWidget {
  const _ItemsView({
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
        return const Center(
          child: Text('Not implemented'),
        );
        /* return Column(
          children: [
            Flexible(
              flex: 2,
              child: Align(
                child: InfiniteCarousel.builder(
                  itemCount: items.entries.length,
                  itemExtent: MediaQuery.of(context).size.width,
                  center: false,
                  velocityFactor: 1,
                  onIndexChanged: (index) {},
                  loop: false,
                  itemBuilder: (context, itemIndex, realIndex) {
                    return Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(1),
                      child: LoadMedia(
                        mediaInfo: CLMediaImage(
                          path: items.entries[realIndex].path,
                          type: items.entries[realIndex].type,
                        ),
                        onMediaLoaded: (mediaData) {
                          return switch (mediaData) {
                            (final CLMediaImage image)
                                when mediaData.runtimeType == CLMediaImage =>
                              Image.file(
                                File(image.previewPath!),
                              ),
                            (final CLMediaVideo video)
                                when mediaData.runtimeType == CLMediaVideo =>
                              VideoPlayerScreen(
                                path: video.path,
                                aspectRatio: mediaData.aspectRatio,
                              ),
                            _ => throw UnimplementedError(
                                'Not yet implemented',
                              )
                          };
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Flexible(
              child: TextField(
                maxLines: 100,
                decoration: const InputDecoration(
                  labelText: 'About',
                  helperText: 'Tab on the text to edit',
                  enabled: false, // Disable editing
                  suffixIcon: CLIcon.standard(Icons.edit_outlined),
                ),
                controller:
                    TextEditingController(text: items.cluster.description),
                onTap: () {},
                onChanged: (value) {}, // Set initial text
              ),
            ),
          ],
        ); */
      },
    );
  }
}
