import 'package:flutter/foundation.dart';

import '../../storage_service/models/file_system/models/cl_directories.dart';

@immutable
class AppSettings {
  const AppSettings(this.directories);
  final CLDirectories directories;
  String get dbName => 'keepIt.db';
}
