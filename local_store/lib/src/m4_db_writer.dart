import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';
import 'm3_db_reader.dart';
import 'm4_db_exec.dart';

@immutable
class DBWriter {
  const DBWriter({
    required this.collectionTable,
    required this.mediaTable,
    required this.notesOnMediaTable,
  });
  final DBExec<Collection> collectionTable;
  final DBExec<CLMedia> mediaTable;

  final DBExec<NotesOnMedia> notesOnMediaTable;

  Future<Collection> upsertCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    return (await collectionTable.upsert(
      tx,
      collection,
      uniqueColumn: ['id', 'label'],
    ))!;
  }

  Future<CLMedia> upsertMedia(
    SqliteWriteContext tx,
    CLMedia media, {
    List<CLMedia>? parents,
  }) async {
    final mediaInDB = (await mediaTable.upsert(
      tx,
      media,
      uniqueColumn: ['id', 'md5String'],
    ))!;
    if (parents?.isNotEmpty ?? false) {
      for (final parent in parents!) {
        await connectNote(tx, note: mediaInDB, media: parent);
      }
    }
    return mediaInDB;
  }

  Future<void> deleteCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    await collectionTable.delete(tx, collection);
  }

  Future<void> deleteMedia(
    SqliteWriteContext tx,
    CLMedia media, {
    required bool permanent,
  }) async {
    if (permanent) {
      // PATCH ============================================================
      // This patch is required as for some reasons, DELETE on CASCASDE
      // didn't work.
      // check if this media is used as supplement for any other media

      final parents = await DBReader(tx).getMediaByNoteID(media.id!);
      if (parents?.isNotEmpty ?? false) {
        for (final parent in parents!) {
          await disconnectNote(tx, note: media, media: parent);
        }
      }
      // check if this media has supplement media
      final children = await DBReader(tx).getNotesByMediaID(media.id!);
      if (children?.isNotEmpty ?? false) {
        for (final child in children!) {
          await disconnectNote(tx, note: child, media: media);
        }
      }

      await mediaTable.delete(tx, media);
    } else {
      // Soft Delete
      await upsertMedia(
        tx,
        media.removePin().copyWith(isDeleted: true),
      );
    }
  }

  Future<void> connectNote(
    SqliteWriteContext tx, {
    required CLMedia note,
    required CLMedia media,
  }) async {
    await notesOnMediaTable.upsert(
      tx,
      NotesOnMedia(noteId: note.id!, mediaId: media.id!),
      ignore: true,
      uniqueColumn: [],
    );
  }

  Future<void> disconnectNote(
    SqliteWriteContext tx, {
    required CLMedia note,
    required CLMedia media,
  }) async {
    await notesOnMediaTable.delete(
      tx,
      NotesOnMedia(noteId: note.id!, mediaId: media.id!),
      identifier: ['noteId', 'mediaId'],
    );
  }

  Future<Collections> upsertCollections(
    SqliteWriteContext tx, {
    required Collections collections,
  }) async {
    return Collections(
      await collectionTable.upsertAll(
        tx,
        collections.entries,
        uniqueColumn: ['id', 'label'],
      ),
    );
  }

  Future<CLMedias> upsertMedias(
    SqliteWriteContext tx, {
    required CLMedias medias,
  }) async {
    return CLMedias(
      await mediaTable.upsertAll(
        tx,
        medias.entries,
        uniqueColumn: ['id', 'md5String'],
      ),
    );
  }
}

const _filePrefix = 'DB Write: ';
bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
