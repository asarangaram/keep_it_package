import 'dart:io';

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

  String get dbName => 'keepIt.db';

  Directory get mediaDirectory =>
      directories.standardDirectory(CLStandardDirectories.mediaPersistent).path;

  String get downloadedMediaDirectoryPath => directories
      .standardDirectory(CLStandardDirectories.downloadedMediaPreserved)
      .path
      .path;
  String get backupDirectoryPath => directories
      .standardDirectory(CLStandardDirectories.backupPersistent)
      .path
      .path;
  String get thumbnailDirectoryPath => directories
      .standardDirectory(CLStandardDirectories.tempThumbnail)
      .path
      .path;

  String get databaseDirectoryPath => directories
      .standardDirectory(CLStandardDirectories.dbPersistent)
      .path
      .path;
}
