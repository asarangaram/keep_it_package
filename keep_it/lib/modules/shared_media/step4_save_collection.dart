import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/modules/shared_media/cl_media_process.dart';
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
      final streamController = StreamController<Progress>();
      var completedMedia = 0;
      unawaited(
        dbManager
            .upsertMediaMultiple(
          media: media,
          collection: updatedCollection,
          onPrepareMedia: (m, {required targetDir}) async {
            final updated =
                (await m.moveFile(targetDir: targetDir)).getMetadata();
            completedMedia++;

            streamController.add(
              Progress(
                fractCompleted: completedMedia / media!.length,
                currentItem: m.basename,
              ),
            );
            await Future<void>.delayed(const Duration(microseconds: 1));
            return updated;
          },
        )
            .then((updatedMedia) async {
          streamController.add(
            const Progress(
              fractCompleted: 1,
              currentItem: 'successfully imported',
            ),
          );
          await Future<void>.delayed(const Duration(microseconds: 10));
          await streamController.close();
          onDone();
        }),
      );
      yield* streamController.stream;
    }
  }
}
