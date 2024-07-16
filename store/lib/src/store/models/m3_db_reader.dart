import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'm3_db_queries.dart';
import 'm3_db_query.dart';

@immutable
class DBReader {
  const DBReader();

  Future<CLMedia?> getMediaByMD5(
    SqliteWriteContext tx,
    String md5String,
  ) async {
    return (DBQueries.mediaByMD5.sql as DBQuery<CLMedia>)
        .copyWith(parameters: [md5String]).read(tx);
  }

  Future<CLMedia?> getMediaById(
    SqliteWriteContext tx,
    int id,
  ) async {
    return (await (DBQueries.mediaById.sql as DBQuery<CLMedia>)
            .copyWith(parameters: [id]).readMultiple(
      tx,
    ))
        .firstOrNull;
  }

  Future<List<CLMedia>> getMediaByCollectionId(
    SqliteWriteContext tx,
    int collectionId,
  ) async {
    return (DBQueries.mediaByCollectionId.sql as DBQuery<CLMedia>)
        .copyWith(parameters: [collectionId]).readMultiple(
      tx,
    );
  }

  Future<Collection?> getCollectionByLabel(
    SqliteWriteContext tx,
    String label,
  ) async {
    return (DBQueries.collectionByLabel.sql as DBQuery<Collection>)
        .copyWith(parameters: [label]).read(tx);
  }

  Future<List<CLNote>?> getNotesByMediaID(
    SqliteWriteContext tx,
    int noteId,
  ) {
    return (DBQueries.notesByMediaId.sql as DBQuery<CLNote>)
        .copyWith(parameters: [noteId]).readMultiple(
      tx,
    );
  }

  Future<List<CLMedia>?> getMediaByNoteID(
    SqliteWriteContext tx,
    int noteId,
  ) async {
    return (DBQueries.mediaByNoteID.sql as DBQuery<CLMedia>)
        .copyWith(parameters: [noteId]).readMultiple(
      tx,
    );
  }

  Future<List<CLNote>?> getOrphanNotes(
    SqliteWriteContext tx,
  ) {
    return (DBQueries.notesOrphan.sql as DBQuery<CLNote>).readMultiple(tx);
  }
}
