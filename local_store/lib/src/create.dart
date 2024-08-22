import 'package:device_resources/device_resources.dart';
import 'package:store/store.dart';
import 'm2_db_manager.dart';

Future<Store> createStoreInstance(
  String fullPath, {
  required void Function() onReload,
  required AppSettings appSettings,
  CLServer? server,
}) async {
  return DBManager.createInstances(
    dbpath: fullPath,
    onReload: onReload,
    server: server,
    appSettings: appSettings,
  );
}
