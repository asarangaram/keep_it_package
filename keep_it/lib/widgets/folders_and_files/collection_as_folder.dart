import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/widgets/editors/collection_editor.dart';
import 'package:store/store.dart';

import '../wrap_standard_quick_menu.dart';

class CollectionAsFolder extends ConsumerWidget {
  const CollectionAsFolder({
    required this.collection,
    required this.quickMenuScopeKey,
    super.key,
  });
  final Collection collection;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return WrapStandardQuickMenu(
          quickMenuScopeKey: quickMenuScopeKey,
          onEdit: () async {
            final res = await CollectionEditor.popupDialog(
              context,
              collection: collection,
            );
            if (res != null) {
              final (collection, tags) = res;
              await dbManager.upsertCollection(
                collection: collection,
                newTagsListToReplace: tags,
              );

              await ref
                  .read(notificationMessageProvider.notifier)
                  .push('Updated');
            }

            return true;
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: CLText.large(
                    'Are you sure you want to delete '
                    '"${collection.label}" and its content?',
                  ),
                  actions: [
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
            if (confirmed ?? false) {
              await dbManager.deleteCollection(
                collection,
                onDeleteMediaFiles: (media) async {
                  for (final m in media) {
                    m.deleteFile();
                  }
                },
              );
            }
            return null;
          },
          onTap: () async {
            unawaited(
              context.push(
                '/items/${collection.id}',
              ),
            );
            return true;
          },
          child: Column(
            children: [
              Flexible(
                child: PreviewGenerator(
                  collection: collection,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  collection.label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteCollection(
    DBManager dbManager,
    Collection collection,
  ) async {}
}

class PreviewGenerator extends StatelessWidget {
  const PreviewGenerator({
    required this.collection,
    super.key,
  });
  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return GetMediaMultiple(
      collectionId: collection.id,
      buildOnData: (items) {
        return CLAspectRationDecorated(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CLMediaCollage.byMatrixSize(
            items,
            hCount: 2,
            vCount: 2,
            itemBuilder: (context, index) => CLMediaPreview(
              media: items[index],
              keepAspectRatio: false,
            ),
            whenNopreview: Center(
              child: CLText.veryLarge(
                collection.label.characters.first,
              ),
            ),
          ),
        );
      },
    );
  }
}
