import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:store/store.dart';

import 'wizard_page.dart';

class SaveCollection extends SharedMediaWizard {
  const SaveCollection({
    required super.incomingMedia,
    required super.onDone,
    required super.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return StreamProgressView(
          stream: () => acceptMedia(
            dbManager,
            collection: incomingMedia.collection!,
            newTagsListToReplace: incomingMedia.tags == null
                ? null
                : List.from(incomingMedia.tags!),
            media: List.from(incomingMedia.entries),
            onDone: () {
              onDone(mg: null);
            },
          ),
          onCancel: onCancel,
        );
      },
    );
  }

  static Stream<Progress> acceptMedia(
    DBManager dbManager, {
    required Collection collection,
    required List<Tag>? newTagsListToReplace,
    required List<CLMedia>? media,
    required void Function() onDone,
  }) async* {
    {
      final Collection updatedCollection;
      if (collection.id == null) {
        yield const Progress(
          fractCompleted: 0,
          currentItem: 'creating new collection',
        );
        updatedCollection = await dbManager.upsertCollection(
          collection: collection,
          newTagsListToReplace: newTagsListToReplace,
        );
      } else {
        updatedCollection = collection;
      }

      if (media?.isNotEmpty ?? false) {
        final updatedMedia = <CLMedia>[];
        for (final (i, item) in media!.indexed) {
          yield Progress(
            fractCompleted: i / media.length,
            currentItem: 'adding ${path.basename(media[0].path)}',
          );
          var updated = item.copyWith(collectionId: updatedCollection.id);
          updated = await updated.moveFile(
            targetDir: dbManager.dbWriter.appSettings
                .validPrefix(updatedCollection.id!),
          );
          updatedMedia.add(updated);
        }
        yield const Progress(
          fractCompleted: 1,
          currentItem: 'updating Store',
        );
        await dbManager.upsertMediaMultiple(updatedMedia);
      }
      yield const Progress(
        fractCompleted: 1,
        currentItem: 'successfully imported',
      );

      onDone();
    }
  }
}
