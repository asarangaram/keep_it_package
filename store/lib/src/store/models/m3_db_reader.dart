import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'm3_db_queries.dart';
import 'm3_db_query.dart';

@immutable
class DBReader {
  const DBReader({required this.appSettings});
  final AppSettings appSettings;
  Future<CLMedia?> getMediaByMD5(
    SqliteWriteContext tx,
    String md5String,
  ) async {
    return (DBQueries.mediaByMD5.sql as DBQuery<CLMedia>)
        .copyWith(parameters: [md5String]).read(
      tx,
      appSettings: appSettings,
      validate: true,
    );
  }

  Future<List<CLMedia>> getMediaByCollectionId(
    SqliteWriteContext tx,
    int collectionId,
  ) async {
    return (DBQueries.mediaByCollectionId.sql as DBQuery<CLMedia>)
        .copyWith(parameters: [collectionId]).readMultiple(
      tx,
      appSettings: appSettings,
      validate: true,
    );
  }
}
