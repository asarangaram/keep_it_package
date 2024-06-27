import 'package:colan_widgets/src/models/file_system/models/cl_directories.dart';
import 'package:flutter/foundation.dart';

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
