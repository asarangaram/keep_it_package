import 'package:flutter/foundation.dart';

import 'file_system/models/cl_directories.dart';

@immutable
class AppSettings {
  const AppSettings(
    this.directories, {
    this.shouldValidate = true,
  });
  final CLDirectories directories;
  final bool shouldValidate;

  String validPrefix(int collectionID) =>
      '${directories.media.pathString}/cluster_$collectionID';

  String validRelativePrefix(int collectionID) => 'cluster_$collectionID';

  String get dbName => 'keepIt.db';
}
