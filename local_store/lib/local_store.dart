/// Implementation using sqlite async
library;

import 'package:store/store.dart';

import 'src/db_store.dart';

Future<DBStoreBase> createDBStoreInstance(
  String fullPath, {
  required void Function() onReload,
}) async {
  return DBStore.createInstances(
    dbpath: fullPath,
    onReload: onReload,
  );
}
