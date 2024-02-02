import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';
import '../widgets/keep_media_wizard/description_editor.dart';

import '../widgets/video_player.dart';

class ItemsView extends ConsumerWidget {
  const ItemsView({required this.collectionID, super.key});

  final int collectionID;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadItems(
      collectionID: collectionID,
      buildOnData: (Items items) {
        return KeepItMainView(
          title: items.collection.label,
          onPop: context.canPop()
              ? () {
                  context.pop();
                }
              : null,
          actionsBuilder: [
            (context, quickMenuScopeKey) => CLButtonIcon.standard(
                  Icons.add,
                  onTap: () => onAddItems(context, ref, items.collection),
                ),
          ],
          pageBuilder: (context, quickMenuScopeKey) {
            return Column(
              children: [
                if (items.collection.description != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DescriptionEditor(
                      items.collection,
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                ] else
                  const SizedBox(
                    height: 16,
                  ),
                Expanded(
                  child: CLMatrix2D(
                    itemCount: items.entries.length,
                    columns: 1,
                    itemBuilder: (context, index, l) {
                      final e = items.entries[index];
                      if (l > 0) {
                        throw Exception('has only one layer!');
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: ItemView(media: e),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

Future<bool> onAddItems(
  BuildContext context,
  WidgetRef ref,
  Collection collection,
) async {
  return onPickFiles(context, ref, collectionId: collection.id);
}

class ItemView extends ConsumerWidget {
  const ItemView({required this.media, super.key});
  final CLMedia media;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (media.type.isFile && !File(media.path).existsSync()) {
      throw Exception('File not found ${media.path}');
    }
    return Card(
      elevation: 8,
      color: Colors.transparent,
      child: File(media.path).existsSync()
          ? switch (media) {
              (final image) when image.type == CLMediaType.image => Image.file(
                  File(image.path),
                ),
              (final video) when video.type == CLMediaType.video =>
                VideoPlayerScreen(
                  path: video.path,
                ),
              _ => throw UnimplementedError(
                  'Not yet implemented',
                )
            }
          : const Text('Media not found'),
    );
  }
}

/*

Column(
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
                    TextEditingController(text: items.collection.description),
                onTap: () {},
                onChanged: (value) {}, // Set initial text
              ),
            ),
          ],
        ); */
