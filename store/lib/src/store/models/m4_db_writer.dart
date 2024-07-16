import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'm3_db_queries.dart';
import 'm3_db_query.dart';
import 'm3_db_reader.dart';
import 'm4_db_exec.dart';

@immutable
class DBWriter {
  DBWriter();
  final DBExec<Collection> collectionTable = DBExec<Collection>(
    table: 'Collection',
    toMap: (obj) {
      return obj.toMap();
    },
    readBack: (
      tx,
      collection,
    ) async {
      return (DBQueries.collectionByLabel.sql as DBQuery<Collection>)
          .copyWith(parameters: [collection.label]).read(tx);
    },
  );

  final DBExec<CLMedia> mediaTable = DBExec<CLMedia>(
    table: 'Item',
    toMap: (CLMedia obj) => obj.toMap(),
    readBack: (tx, item) {
      return (DBQueries.mediaByPath.sql as DBQuery<CLMedia>)
          .copyWith(parameters: [item.label]).read(tx);
    },
  );
  final DBExec<CLNote> notesTable = DBExec<CLNote>(
    table: 'Notes',
    toMap: (CLNote obj) => obj.toMap(),
    readBack: (tx, item) async {
      return (DBQueries.noteByPath.sql as DBQuery<CLNote>)
          .copyWith(parameters: [item.path]).read(tx);
    },
  );
  final DBExec<NotesOnMedia> notesOnMediaTable = DBExec<NotesOnMedia>(
    table: 'ItemNote',
    toMap: (NotesOnMedia obj) => obj.toMap(),
    readBack: (tx, item) async {
      // TODO(anandas): :readBack for ItemNote Can this be done?
      return item;
    },
  );

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

  Future<void> deleteCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    if (collection.id == null) return;

    final items =
        await const DBReader().getMediaByCollectionId(tx, collection.id!);

    /// Delete all media ignoring those already in Recycle
    /// Don't delete CollectionDir / Collection from Media, required for restore

    for (final m in items) {
      if (!(m.isDeleted ?? false)) {
        await deleteMedia(
          tx,
          m,
          deletePermanently: false,
        );
      }
    }
  }

  Future<void> deleteOrphanNotes(
    SqliteWriteContext tx,
  ) async {
    final notes = await const DBReader().getOrphanNotes(tx);
    if (notes != null && notes.isNotEmpty) {
      for (final note in notes) {
        await deleteNote(tx, note);
      }
    }
  }

  Future<void> deleteMedia(
    SqliteWriteContext tx,
    CLMedia media, {
    required bool deletePermanently,
  }) async {
    if (deletePermanently) {
      final notes = await const DBReader().getNotesByMediaID(tx, media.id!);
      if (notes != null && notes.isNotEmpty) {
        for (final n in notes) {
          await notesOnMediaTable.delete(
            tx,
            {'noteId': n.id!.toString(), 'itemId': media.id!.toString()},
          );
        }
      }

      await mediaTable.delete(tx, {'id': media.id.toString()});
    } else {
      // Soft Delete
      await upsertMedia(
        tx,
        media.removePin().copyWith(isDeleted: true),
      );
    }
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

  Future<void> pinMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  }) async {
    final unpinned = media.where((e) => e.pin == null).toList();
    for (final item in unpinned) {
      await togglePin(tx, item, onPin: onPin, onRemovePin: onRemovePin);
    }
  }

  Future<bool> unpinMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media, {
    required Future<bool> Function(List<String> ids) onRemovePinMultiple,
  }) async {
    final pinned = media.where((e) => e.pin != null).toList();
    final bool res;
    if (pinned.isNotEmpty) {
      res = await onRemovePinMultiple(pinned.map((e) => e.pin!).toList());
    } else {
      res = true;
    }

    if (res) {
      for (final item in pinned) {
        final pinnedMedia = item.removePin();
        await upsertMedia(tx, pinnedMedia);
      }
    }
    return res;
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

    final media = await const DBReader().getMediaByNoteID(tx, note.id!);
    if (media != null && media.isNotEmpty) {
      for (final m in media) {
        await notesOnMediaTable.delete(
          tx,
          {'noteId': note.id!.toString(), 'itemId': m.id!.toString()},
        );
      }
    }

    await notesTable.delete(tx, {'id': note.id.toString()});
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
