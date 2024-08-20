import 'package:local_store/src/cl_server.dart';
import 'package:store/store.dart';
import 'm2_db_manager.dart';

Future<Store> createStoreInstance(
  String fullPath, {
  required void Function() onReload,
  CLServer? server,
}) async {
  return DBManager.createInstances(
    dbpath: fullPath,
    onReload: onReload,
    server: server,
  );
}
