import 'package:cl_entity_viewers/cl_entity_viewers.dart';
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
      final updated = await (await item.updateWith(
        parentId: () => parentCollection.id!,
        isHidden: () => false,
      ))
          ?.dbSave();
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
