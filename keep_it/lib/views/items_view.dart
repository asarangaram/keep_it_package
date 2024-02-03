import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/dialogs.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';
import '../widgets/keep_media_wizard/description_editor.dart';

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
                  onTap: () => KeepItDialogs.onAddItemsIntoCollection(
                    context,
                    ref,
                    items.collection,
                  ),
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
                      return GestureDetector(
                        onTap: () =>
                            context.push('/item/${e.collectionId}/${e.id}'),
                        child: Hero(
                          tag: '/item/${e.collectionId}/${e.id}',
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CLMediaPreview(
                              media: e,
                            ),
                          ),
                        ),
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

/* class ItemView extends ConsumerWidget {
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
} */
