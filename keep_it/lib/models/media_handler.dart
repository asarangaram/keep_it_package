// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';

import 'file_system_manager.dart';

@immutable
class MediaHandler {
  const MediaHandler({
    required this.fsManager,
    required this.store,
    required this.albumManager,
  });
  final FileSystemManager fsManager;
  final Store store;

  static const tempCollectionName = '*** Recently Captured';
  final AlbumManager albumManager;

  Future<List<CLMedia?>> getMediaByCollectionId(
    int collectionId,
  ) {
    final q = store.getQuery(
      DBQueries.mediaByCollectionId,
      parameters: [collectionId],
    ) as StoreQuery<CLMedia>;
    return store.readMultiple(q);
  }

  Future<List<CLMedia?>> getMediaMultipleByIds(
    List<int> idList,
  ) {
    final q = store.getQuery(
      DBQueries.mediaByIdList,
      parameters: ['(${idList.join(', ')})'],
    ) as StoreQuery<CLMedia>;
    return store.readMultiple(q);
  }

  Future<List<CLNote?>?> getOrphanNotes() {
    final q = store.getQuery(DBQueries.notesOrphan) as StoreQuery<CLNote>;
    return store.readMultiple(q);
  }

  Future<Collection?> getCollectionByLabel(
    String label,
  ) async {
    final q = store.getQuery(
      DBQueries.collectionByLabel,
      parameters: [label],
    ) as StoreQuery<Collection>;
    return store.read(q);
  }

  Future<CLMedia?> getMediaByMD5(
    String md5String,
  ) async {
    final q = store.getQuery(
      DBQueries.mediaByMD5,
      parameters: [md5String],
    ) as StoreQuery<CLMedia>;
    return store.read(q);
  }

  Future<CLMedia?> newMedia(
    String fileName, {
    required bool isVideo,
    Collection? collection,
  }) async {
    // Get Collection if required
    Collection collection0;
    if (collection == null) {
      collection0 = await getCollectionByLabel(tempCollectionName) ??
          await store.upsertCollection(
            const Collection(label: tempCollectionName),
          );
    } else {
      collection0 = collection;
    }
    final candidate = await fsManager.createMediaCandidate(
      fileName,
      isVideo ? CLMediaType.video : CLMediaType.image,
    );

    final savedMedia = CLMedia(
      path: candidate.basename,
      type: candidate.type,
      collectionId: collection0.id,
      md5String: await candidate.md5String,
      isHidden: collection == null,
    );
    final mediaFromDB = await store.upsertMedia(savedMedia);
    if (mediaFromDB == null) {
      await fsManager.deleteMediaFiles(savedMedia);
    } else {}
    return mediaFromDB;
  }

  Stream<Progress> newMediaMultipleStream({
    required List<CLMediaFile> mediaFiles,
    required void Function({
      required List<CLMedia> mediaMultiple,
    }) onDone,
  }) async* {
    final candidates = <CLMedia>[];
    //await Future<void>.delayed(const Duration(seconds: 3));
    yield Progress(
      currentItem: mediaFiles[0].basename,
      fractCompleted: 0,
    );
    final Collection tempCollection;
    tempCollection = await getCollectionByLabel(tempCollectionName) ??
        await store.upsertCollection(
          const Collection(label: tempCollectionName),
        );
    for (final (i, item0) in mediaFiles.indexed) {
      final candidate =
          await fsManager.tryCreateMediaCandidate(item0.path, item0.type);
      if (candidate != null) {
        final duplicate = await getMediaByMD5(await candidate.md5String);
        if (duplicate != null) {
          candidates.add(duplicate);
        } else {
          final savedMedia = await fsManager.getMetadata(
            CLMedia(
              path: candidate.basename,
              type: candidate.type,
              collectionId: tempCollection.id,
              md5String: await candidate.md5String,
              isHidden: true,
            ),
          );

          final mediaFromDB = await store.upsertMedia(savedMedia);
          if (mediaFromDB != null) {
            candidates.add(mediaFromDB);
          }
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 1));

      yield Progress(
        currentItem:
            (i + 1 == mediaFiles.length) ? '' : mediaFiles[i + 1].basename,
        fractCompleted: (i + 1) / mediaFiles.length,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 1));
    onDone(
      mediaMultiple: candidates,
    );
  }

  Future<CLMedia> replaceMedia(
    CLMedia originalMedia,
    String outFile,
  ) async {
    final candidate =
        await fsManager.createMediaCandidate(outFile, originalMedia.type);

    final updatedMedia = originalMedia
        .copyWith(
          path: candidate.basename,
          type: candidate.type,
          md5String: await candidate.md5String,
        )
        .removePin();

    final mediaFromDB = await store.upsertMedia(
      updatedMedia,
    );
    if (mediaFromDB != null) {
      await fsManager.deleteMediaFiles(originalMedia);
    } else {
      await fsManager.deleteMediaFiles(updatedMedia);
    }

    return mediaFromDB ?? originalMedia;
  }

  Future<CLMedia> cloneAndReplaceMedia(
    CLMedia originalMedia,
    String outFile,
  ) async {
    final candidate =
        await fsManager.createMediaCandidate(outFile, originalMedia.type);

    final CLMedia updatedMedia;
    updatedMedia = originalMedia
        .copyWith(
          path: candidate.basename,
          type: candidate.type,
          md5String: await candidate.md5String,
        )
        .removePin();

    final mediaFromDB = await store.upsertMedia(
      updatedMedia.removeId(),
    );

    return mediaFromDB ?? originalMedia;
  }

  //Can be converted to non static
  Stream<Progress> moveToCollectionStream(
    List<CLMedia> mediaMultiple, {
    required Collection collection,
    required void Function() onDone,
  }) async* {
    final Collection updatedCollection;
    if (collection.id == null) {
      yield const Progress(
        fractCompleted: 0,
        currentItem: 'Creating new collection',
      );
      updatedCollection = await store.upsertCollection(collection);
    } else {
      updatedCollection = collection;
    }

    if (mediaMultiple.isNotEmpty) {
      final streamController = StreamController<Progress>();

      unawaited(
        upsertMediaMultiple(
          mediaMultiple
              .map(
                (e) => e.copyWith(
                  isHidden: false,
                  collectionId: updatedCollection.id,
                ),
              )
              .toList(),
          onProgress: (progress) async {
            streamController.add(progress);
            await Future<void>.delayed(const Duration(microseconds: 1));
          },
        ).then((updatedMedia) async {
          streamController.add(
            const Progress(
              fractCompleted: 1,
              currentItem: 'Successfully Imported',
            ),
          );
          await Future<void>.delayed(const Duration(microseconds: 1));
          await streamController.close();
          onDone();
        }),
      );
      yield* streamController.stream;
    }
  }

  Future<void> upsertMediaMultiple(
    List<CLMedia> mediaMultiple, {
    void Function(Progress progress)? onProgress,
  }) async {
    for (final (i, m) in mediaMultiple.indexed) {
      await store.upsertMedia(m);
      onProgress?.call(
        Progress(
          fractCompleted: i / mediaMultiple.length,
          currentItem: m.label,
        ),
      );
    }
  }

  Future<Collection> upsertCollection(Collection collection) async {
    final updated = await store.upsertCollection(collection);
    return updated;
  }

  Future<bool> restoreMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    for (final item in mediaMultiple) {
      if (item.id != null) {
        await store.upsertMedia(item.copyWith(isDeleted: false));
      }
    }
    return true;
  }

  Future<void> upsertNote(
    String path,
    CLNoteTypes type, {
    required List<CLMedia> mediaMultiple,
    CLNote? originalNote,
  }) async {
    final candidate = await fsManager.createNoteCandidate(path, type);
    final savedNote =
        CLNote.fromNoteFile(noteFile: candidate, originalNote: originalNote);

    final notesInDB = await store.upsertNote(
      savedNote,
      mediaMultiple,
    );
    if (notesInDB == null) {
      await candidate.delete();
    } else {
      await fsManager.deleteNoteFiles(originalNote);
    }
  }

  Future<void> onDeleteNote(CLNote note) async {
    if (note.id == null) return;

    await store.deleteNote(note);
    await fsManager.deleteNoteFiles(note);
  }

  Future<bool> permanentlyDeleteMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    // Remove Pins first..
    await removeMultipleMediaFromGallery(
      pinnedMedia.map((e) => e.pin!).toList(),
    );

    for (final m in mediaMultiple) {
      await store.deleteMedia(m, permanent: true);
      await fsManager.deleteMediaFiles(m);
    }
    final orphanNotes = await getOrphanNotes();
    if (orphanNotes != null) {
      for (final note in orphanNotes) {
        if (note != null) {
          await store.deleteNote(note);
          await fsManager.deleteNoteFiles(note);
        }
      }
    }
    return true;
  }

  Future<bool> deleteMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    // Remove Pins first..
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    // Remove Pins first..
    await removeMultipleMediaFromGallery(
      pinnedMedia.map((e) => e.pin!).toList(),
    );

    for (final m in mediaMultiple) {
      await store.deleteMedia(m, permanent: false);
    }
    return true;
  }

  Future<bool> togglePinMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.any((e) => e.pin == null)) {
      return pinMediaMultiple(mediaMultiple);
    } else {
      return removePinMediaMultiple(mediaMultiple);
    }
  }

  Future<bool> removePinMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    final res = await removeMultipleMediaFromGallery(
      pinnedMedia.map((e) => e.pin!).toList(),
    );
    if (res) {
      await upsertMediaMultiple(pinnedMedia.map((e) => e.removePin()).toList());
    }
    return res;
  }

  Future<bool> pinMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final updatedMedia = <CLMedia>[];
    for (final media in mediaMultiple) {
      if (media.id != null) {
        final pin = await albumManager.addMedia(
          fsManager.getMediaPath(media),
          title: media.path,
          isImage: media.type == CLMediaType.image,
          isVideo: media.type == CLMediaType.video,
          desc: 'KeepIT',
        );
        if (pin != null) {
          updatedMedia.add(media.copyWith(pin: pin));
        }
      }
    }
    await upsertMediaMultiple(updatedMedia);
    return true;
  }

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

  Future<bool> removeMediaFromGallery(
    String ids,
  ) async {
    final res = await albumManager.removeMedia(ids);
    /* if (!res) {
      if (ctx.mounted) {
        await ref
            .read(
              notificationMessageProvider.notifier,
            )
            .push(
              'Failed: Did you give permission to remove from Gallery?',
            );
      }
    } */
    return res;
  }

  Future<bool> removeMultipleMediaFromGallery(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return true;
    final res = await albumManager.removeMultipleMedia(ids);
    /* if (!res) {
      if (ctx.mounted) {
        await ref
            .read(
              notificationMessageProvider.notifier,
            )
            .push(
              'Failed: Did you give permission to remove from Gallery?',
            );
      }
    } */
    return res;
  }

  Future<void> reloadStore() async {
    await store.reloadStore();
  }
}
