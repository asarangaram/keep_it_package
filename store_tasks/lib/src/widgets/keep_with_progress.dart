import 'dart:io';

import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class KeepWithProgress extends StatelessWidget implements PreferredSizeWidget {
  const KeepWithProgress({
    required this.media2Move,
    required this.newParent,
    required this.onDone,
    super.key,
  });
  final ViewerEntities media2Move;
  final StoreEntity newParent;

  final void Function() onDone;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Progress>(
      stream: moveMultiple(
        items: media2Move,
        newParent: newParent,
        onDone: ({
          required ViewerEntities mediaMultiple,
        }) async =>
            onDone(),
      ),
      builder: (context, snapShot) {
        return ProgressBar(
          progress: snapShot.hasData ? snapShot.data?.fractCompleted : null,
        );
      },
    );
  }

  Stream<Progress> moveMultiple({
    required ViewerEntities items,
    required StoreEntity newParent,
    required Future<void> Function({
      required ViewerEntities mediaMultiple,
    }) onDone,
  }) async* {
    final parentCollection = await newParent.dbSave();
    if (parentCollection == null || parentCollection.id == null) {
      throw Exception('failed to save parent collection');
    }

    final updatedItems = <StoreEntity>[];
    for (final (i, item) in items.entities.cast<StoreEntity>().indexed) {
      yield Progress(fractCompleted: (i + 1) / items.length, currentItem: '');
      final StoreEntity? updated;
      if (parentCollection.store == item.store) {
        updated = await (await item.updateWith(
          parentId: () => parentCollection.id!,
          isHidden: () => false,
        ))
            ?.dbSave();
      } else {
        final targetStore = parentCollection.store;
        if (item.store.store.isLocal) {
          updated = await (await targetStore.createMedia(
                  label: () => item.data.label,
                  description: () => item.data.description,
                  parentCollection: parentCollection.data,
                  mediaFile: CLMediaFile(
                      path: item.mediaUri!.toFilePath(),
                      md5: item.data.md5!,
                      fileSize: item.data.fileSize!,
                      mimeType: item.data.mimeType!,
                      type: CLMediaType.fromMIMEType(item.data.type!),
                      fileSuffix: item.data.extension!,
                      createDate: item.data.createDate,
                      height: item.data.height,
                      width: item.data.width,
                      duration: item.data.duration),
                  strategy: UpdateStrategy.mergeAppend))
              ?.dbSave(item.mediaUri!.toFilePath());
          if (updated != null) {
            final filePath = item.mediaUri!.toFilePath();

            await item.delete();
            await File(filePath).deleteIfExists();
          }
        } else {
          updated = null;
        }
      }

      if (updated == null) {
        throw Exception('Failed to update item ${item.id}');
      }
      updatedItems.add(updated);
    }
    yield const Progress(fractCompleted: 1, currentItem: 'All items are moved');
    await onDone(mediaMultiple: ViewerEntities(updatedItems));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension * 3);
}
