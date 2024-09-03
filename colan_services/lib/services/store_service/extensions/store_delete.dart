import 'dart:io';

import 'package:store/store.dart';

import '../../store_service/store_service.dart';

extension DeleteExtOnStoreManager on StoreManager {
  Future<bool> deleteCollection(
    Collection collection,
  ) async {
    if (collection.id == null) return true;

    final mediaMultiple = await getMediaByCollectionId(collection.id!);

    /// Delete all media ignoring those already in Recycle
    /// Don't delete CollectionDir / Collection from Media, required for restore

    await deleteMediaMultiple(
      mediaMultiple.where((e) => e != null).map((e) => e!).toList(),
    );
    return true;
  }

  Future<void> deleteMedia(
    CLMedia media, {
    bool permanent = false,
  }) async {
    if (media.id == null) return;

    await store.deleteMedia(media, permanent: true);
    if (permanent) {
      await File(getMediaAbsolutePath(media)).deleteIfExists();
      await File(getPreviewAbsolutePath(media)).deleteIfExists();

      final orphanNotesQuery = store.getQuery<CLMedia>(DBQueries.notesOrphan);

      final orphanNotes = await store.readMultiple(orphanNotesQuery);
      if (orphanNotes.isNotEmpty) {
        for (final note in orphanNotes) {
          if (note != null) {
            await store.deleteMedia(note, permanent: true);
            await File(getMediaAbsolutePath(note)).deleteIfExists();
            await File(getPreviewAbsolutePath(media)).deleteIfExists();
          }
        }
      }
    }
  }

  Future<void> onDeleteNote(CLMedia note) async {
    await store.deleteMedia(note, permanent: true);
  }
}
