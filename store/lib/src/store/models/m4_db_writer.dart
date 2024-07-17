// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

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
    Collection collection,
  ) async {
    _infoLogger('upsertCollection: $collection');
    final updated = await collectionTable.upsert(
      tx,
      collection,
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
    List<CLMedia> media,
  ) async {
    _infoLogger('upsertMediaMultiple: $media');
    final updated = await mediaTable.upsertAll(
      tx,
      media,
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

  Future<CLMedia> upsertMedia(SqliteWriteContext tx, CLMedia media) async {
    _infoLogger('upsertMedia: $media');
    final updated = await mediaTable.upsert(
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

  Future<void> deleteMedia(
    SqliteWriteContext tx,
    CLMedia media,
  ) async {
    await mediaTable.delete(tx, {'id': media.id.toString()});
  }

  Future<bool> togglePin(
    SqliteWriteContext tx,
    CLMedia media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  }) async {
    if (media.id == null) return false;

    if (media.pin == null || media.pin!.isEmpty) {
      final pin = await onPin(media, title: media.label);
      if (pin == null) return false;
      final pinnedMedia = media.copyWith(pin: pin);
      await upsertMedia(tx, pinnedMedia);
      return true;
    } else {
      final id = media.pin!;
      final res = await onRemovePin(id);
      if (res) {
        final pinnedMedia = media.removePin();
        await upsertMedia(tx, pinnedMedia);
      }
      return res;
    }
  }

  Future<bool> removePin(
    SqliteWriteContext tx,
    CLMedia media, {
    required Future<bool> Function(String id) onRemovePin,
  }) async {
    if (media.id == null) return false;

    if (media.pin == null || media.pin!.isEmpty) {
      return false;
    } else {
      final id = media.pin!;
      final res = await onRemovePin(id);
      if (res) {
        final pinnedMedia = media.removePin();
        await upsertMedia(tx, pinnedMedia);
      }
      return res;
    }
  }

  Future<CLNote> upsertNote(
    SqliteWriteContext tx,
    CLNote note,
    List<CLMedia> mediaList,
  ) async {
    _infoLogger('upsertNote: $note');

    final updated = await notesTable.upsert(
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
        );
      }
    }
    return updated!;
  }

  Future<void> deleteNote(
    SqliteWriteContext tx,
    CLNote note,
  ) async {
    if (note.id == null) return;

    await notesTable.delete(tx, {'id': note.id.toString()});
  }

  Future<void> disconnectNotes(
    SqliteWriteContext tx, {
    required CLNote note,
    required CLMedia media,
  }) async {
    await notesOnMediaTable.delete(
      tx,
      {'noteId': note.id!.toString(), 'itemId': media.id!.toString()},
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
