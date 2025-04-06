import 'package:meta/meta.dart';

@immutable
abstract class DBModel {
  const DBModel();

  Future<void> reloadStore();
  Future<void> dispose();
}
