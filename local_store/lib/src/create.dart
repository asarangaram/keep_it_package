import 'package:colan_widgets/colan_widgets.dart';
import 'm2_db_manager.dart';

Future<Store> createStoreInstance(
  String fullPath, {
  required void Function() onReload,
}) async {
  return DBManager.createInstances(
    dbpath: fullPath,
    onReload: onReload,
  );
}
