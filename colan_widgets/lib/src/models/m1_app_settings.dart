// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

@immutable
class DeviceDirectories {
  const DeviceDirectories({
    required this.container,
    required this.docDir,
    required this.cacheDir,
    required this.systemTemp,
  });
  final Directory container;
  final Directory docDir;
  final Directory cacheDir;
  final Directory systemTemp;

  DeviceDirectories copyWith({
    Directory? container,
    Directory? docDir,
    Directory? cacheDir,
    Directory? systemTemp,
  }) {
    return DeviceDirectories(
      container: container ?? this.container,
      docDir: docDir ?? this.docDir,
      cacheDir: cacheDir ?? this.cacheDir,
      systemTemp: systemTemp ?? this.systemTemp,
    );
  }

  @override
  bool operator ==(covariant DeviceDirectories other) {
    if (identical(this, other)) return true;

    return other.container == container &&
        other.docDir == docDir &&
        other.cacheDir == cacheDir &&
        other.systemTemp == systemTemp;
  }

  @override
  int get hashCode {
    return container.hashCode ^
        docDir.hashCode ^
        cacheDir.hashCode ^
        systemTemp.hashCode;
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'DeviceDirectories(container: $container, docDir: $docDir, cacheDir: $cacheDir, tmpDirectory: $systemTemp)';
  }
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
  Directory get downloadDir =>
      Directory(join(directories.cacheDir.path, 'downloads'));
}

extension NotesOnAppSettings on AppSettings {
  String get notesDir => '${directories.docDir.path}/keep_it/notes';
}
