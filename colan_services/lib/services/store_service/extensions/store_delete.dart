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

  Future<void> deleteMedia(CLMedia media) async {
    if (media.id == null) return;

    await store.deleteMedia(media);

    await File(getMediaAbsolutePath(media)).deleteIfExists();
    await File(getPreviewAbsolutePath(media)).deleteIfExists();

    final orphanNotesQuery = store.getQuery<CLMedia>(DBQueries.notesOrphan);

    final orphanNotes = await store.readMultiple(orphanNotesQuery);
    if (orphanNotes.isNotEmpty) {
      for (final note in orphanNotes) {
        if (note != null) {
          await store.deleteMedia(note);
          await File(getMediaAbsolutePath(note)).deleteIfExists();
          await File(getPreviewAbsolutePath(media)).deleteIfExists();
        }
      }
    }
    // if foreign key properly works, the following not required
    final pref = await getMediaPreferenceById(media.id!);
    final status = await getMediaStatusById(media.id!);
    if (pref != null) {
      await store.deleteMediaPreference(pref);
    }
    if (status != null) {
      await store.deleteMediaStatus(status);
    }
  }
}
