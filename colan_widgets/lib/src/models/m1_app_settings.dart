import 'dart:io';

import 'package:flutter/foundation.dart';

@immutable
class DeviceDirectories {
  const DeviceDirectories({
    required this.container,
    required this.docDir,
    required this.cacheDir,
  });
  final Directory container;
  final Directory docDir;
  final Directory cacheDir;
}

class AppSettings {
  AppSettings(
    this.directories, {
    this.shouldValidate = true,
  });
  final DeviceDirectories directories;
  final bool shouldValidate;
  String validPrefix(int collectionID) =>
      '${directories.docDir.path}/keep_it/cluster_$collectionID';
  String validRelativePrefix(int collectionID) =>
      'keep_it/cluster_$collectionID';

  String dbName = 'keepIt.db';
}
