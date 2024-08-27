import 'package:flutter/foundation.dart';

import 'file_system/models/cl_directories.dart';

@immutable
class AppSettings {
  const AppSettings(
    this.dir, {
    this.shouldValidate = true,
  });
  final CLDirectories dir;
  final bool shouldValidate;

  String get dbName => 'keepIt.db';
}
