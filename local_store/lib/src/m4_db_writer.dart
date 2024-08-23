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
    required this.mediaServerInfoTable,
  });
  final DBExec<Collection> collectionTable;
  final DBExec<CLMedia> mediaTable;

  final DBExec<NotesOnMedia> notesOnMediaTable;
  final DBExec<MediaServerInfo> mediaServerInfoTable;

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
    CLMedia media,
  ) async {
    return (await mediaTable.upsert(
      tx,
      media,
      uniqueColumn: ['id', 'md5String'],
    ))!;
  }

  Future<CLMedia> upsertNote(
    SqliteWriteContext tx,
    CLMedia note,
    List<CLMedia> mediaList,
  ) async {
    final updatedNote = await mediaTable.upsert(
      tx,
      note,
      uniqueColumn: ['id'],
    );

    _infoLogger('upsertNote: Done :  $updatedNote');

    for (final media in mediaList) {
      await connectNotes(tx, note: updatedNote!, media: media);
    }

    return updatedNote!;
  }

  Future<MediaServerInfo> upsertServerInfo(
    SqliteWriteContext tx,
    MediaServerInfo mediaServerInfo,
  ) async {
    return (await mediaServerInfoTable.upsert(
      tx,
      mediaServerInfo,
      uniqueColumn: ['id', 'serverUID'],
    ))!;
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
      if (permanent) {
        final notes = await DBReader(tx).getNotesByMediaID(media.id!);
        if (notes != null && notes.isNotEmpty) {
          for (final n in notes) {
            await disconnectNotes(tx, note: n, media: media);
          }
        }
      }
      // PATCH ENDS ========================================================

      await mediaTable.delete(tx, media);
    } else {
      // Soft Delete
      await upsertMedia(
        tx,
        media.removePin().copyWith(isDeleted: true),
      );
    }
  }

  Future<void> deleteNote(
    SqliteWriteContext tx,
    CLMedia note,
  ) async {
    // PATCH ============================================================
    // This patch is required as for some reasons, DELETE on CASCASDE
    // didn't work.
    final media = await DBReader(tx).getMediaByNoteID(note.id!);
    if (media != null && media.isNotEmpty) {
      for (final m in media) {
        await disconnectNotes(tx, media: m, note: note);
      }
    }
    // PATCH ENDS ========================================================

    await mediaTable.delete(tx, note);
  }

  Future<void> deleteServerInfo(
    SqliteWriteContext tx,
    MediaServerInfo mediaServerInfo,
  ) async {
    await mediaServerInfoTable.delete(tx, mediaServerInfo);
  }

  Future<void> connectNotes(
    SqliteWriteContext tx, {
    required CLMedia note,
    required CLMedia media,
  }) async {
    await notesOnMediaTable.upsert(
      tx,
      NotesOnMedia(noteId: note.id!, itemId: media.id!),
      ignore: true,
      uniqueColumn: [],
    );
  }

  Future<void> disconnectNotes(
    SqliteWriteContext tx, {
    required CLMedia note,
    required CLMedia media,
  }) async {
    await notesOnMediaTable.delete(
      tx,
      NotesOnMedia(noteId: note.id!, itemId: media.id!),
      identifier: ['noteId', 'itemId'],
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
