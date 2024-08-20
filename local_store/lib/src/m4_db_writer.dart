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
    _infoLogger('upsertCollection: $collection');
    final updated = await collectionTable.upsert(
      tx,
      collection,
      isPresent: (id) async => (await getById(id))?.id != null,
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

  Future<List<CLMedia?>> upsertMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media, {
    required Future<List<CLMedia>> Function(List<int>) getByIdList,
  }) async {
    _infoLogger('upsertMediaMultiple: $media');
    final updated = await mediaTable.upsertAll(
      tx,
      media,
      getPresentIdList: (idList) async => (await getByIdList(idList))
          .where((e) => e.id != null)
          .map((e) => e.id!)
          .toList(),
    );
    _infoLogger('upsertMediaMultiple: Done :  $updated');
    if (updated.any((e) => e == null)) {
      exceptionLogger(
        '$_filePrefix: DB Failure',
        '$_filePrefix: Failed to write / retrive Collection',
      );
    }
    return updated;
  }

  Future<CLMedia> upsertMedia(
    SqliteWriteContext tx,
    CLMedia media, {
    required Future<CLMedia?> Function(int id) getById,
  }) async {
    _infoLogger('upsertMedia: $media');
    final updated = await mediaTable.upsert(
      tx,
      media,
      isPresent: (id) async => (await getById(id))?.id != null,
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

    final updated = await notesTable.upsert(
      tx,
      note,
      isPresent: (id) async => (await getById(id))?.id != null,
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
          isPresent: (id) async =>
              false, // Always try to insert, ignore if present
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
