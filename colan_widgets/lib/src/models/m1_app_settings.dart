import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

@immutable
class DeviceDirectories {
  const DeviceDirectories({
    //  required this.container,
    required this.docDir,
    required this.cacheDir,
  });
  // final Directory container;
  final Directory docDir;
  final Directory cacheDir;
}

class AppSettings {
  AppSettings(
    DeviceDirectories directories, {
    this.shouldValidate = true,
  }) : _defaultDirectories = directories;
  final DeviceDirectories _defaultDirectories;
  final bool shouldValidate;

  Directory get _persistentStorage => _defaultDirectories.docDir;
  Directory get _tempStorage => _defaultDirectories.cacheDir;

  String get _parentFolder => 'keep_it';

  String validPrefix(int collectionID) =>
      '${_persistentStorage.path}/$_parentFolder/cluster_$collectionID';
  String validRelativePrefix(int collectionID) =>
      '$_parentFolder/cluster_$collectionID';

  final String _dbName = 'keepIt.db';
  File get databaseFile {
    final dir = Directory(join(_persistentStorage.path, _parentFolder));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return File(join(dir.path, _dbName));
  }

  /// Directories
  ///
  Directory get downloadDir {
    final dir = Directory(join(_tempStorage.path, 'downloads'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  String get pathPrefix => _persistentStorage.path;

  Directory get storeDir {
    final dir = Directory(join(_persistentStorage.path, _parentFolder));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Directory get cacheDir {
    final dir = Directory(join(_tempStorage.path, _parentFolder));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<void> emptyDir() async {
    for (final dir in [
      storeDir,
      cacheDir,
      downloadDir,
    ]) {
      dir.clear();
    }
  }
}
