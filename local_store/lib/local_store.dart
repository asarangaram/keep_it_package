/// Implementation using sqlite async
library;

import 'src/db_store.dart';

Future<DBStoreBase> createDBInstance(
  String fullPath, {
  required void Function() onReload,
}) async {
  return DBStore.createInstances(
    dbpath: fullPath,
    onReload: onReload,
  );
}
