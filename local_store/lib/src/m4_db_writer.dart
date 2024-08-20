import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';
import 'm4_db_exec.dart';

@immutable
class DBWriter {
  const DBWriter({
    required this.collectionTable,
    required this.mediaTable,
    required this.notesTable,
    required this.notesOnMediaTable,
  });
  final DBExec<Collection> collectionTable;
  final DBExec<CLMedia> mediaTable;
  final DBExec<CLNote> notesTable;
  final DBExec<NotesOnMedia> notesOnMediaTable;

  Future<Collection> upsertCollection(
    SqliteWriteContext tx,
    Collection collection, {
    required Future<Collection?> Function(int id) getById,
  }) async {
    final Collection? updated;

    _infoLogger('upsertCollection: $collection');

    updated = await collectionTable.upsert(
      tx,
      collection,
      uniqueColumn: ['id', 'serverUID', 'label'],
    );

    _infoLogger('upsertCollection: Done :  $updated');
    if (updated == null) {
      exceptionLogger(
        '$_filePrefix: DB Failure',
        '$_filePrefix: Failed to write / retrive Collection',
      );
    }
    return updated!;
  }

  Future<CLMedia> upsertMedia(
    SqliteWriteContext tx,
    CLMedia media, {
    required Future<CLMedia?> Function(int id) getById,
  }) async {
    _infoLogger('upsertMedia: $media');

    final updated = await mediaTable.insert(
      tx,
      media,
    );
    _infoLogger('upsertMedia: Done :  $updated');
    if (updated == null) {
      exceptionLogger(
        '$_filePrefix: DB Failure',
        '$_filePrefix: Failed to write / retrive Media',
      );
    }
    return updated!;
  }

  Future<CLNote> upsertNote(
    SqliteWriteContext tx,
    CLNote note,
    List<CLMedia> mediaList, {
    required Future<CLNote?> Function(int id) getById,
  }) async {
    _infoLogger('upsertNote: $note');

    final updated = await notesTable.insert(
      tx,
      note,
    );
    _infoLogger('upsertNote: Done :  $updated');
    if (updated == null) {
      exceptionLogger(
        '$_filePrefix: DB Failure',
        '$_filePrefix: Failed to write / retrive Note',
      );
    } else {
      for (final media in mediaList) {
        await notesOnMediaTable.upsert(
          tx,
          NotesOnMedia(noteId: updated.id!, itemId: media.id!),
          ignore: true,
          uniqueColumn: [],
        );
      }
    }
    return updated!;
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
    required Future<CLMedia?> Function(int id) getById,
  }) async {
    if (permanent) {
      await mediaTable.delete(tx, media);
    } else {
      // Soft Delete
      await upsertMedia(
        tx,
        media.removePin().copyWith(isDeleted: true),
        getById: getById,
      );
    }
  }

  Future<void> deleteNote(
    SqliteWriteContext tx,
    CLNote note,
  ) async {
    if (note.id == null) return;

    await notesTable.delete(tx, note);
  }

  Future<void> disconnectNotes(
    SqliteWriteContext tx, {
    required CLNote note,
    required CLMedia media,
  }) async {
    await notesOnMediaTable.delete(
      tx,
      NotesOnMedia(noteId: note.id!, itemId: media.id!),
      identifier: ['noteId', 'itemId'],
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
