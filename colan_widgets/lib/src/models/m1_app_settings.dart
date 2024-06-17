import 'dart:io';

import 'package:colan_widgets/src/models/file_system/models/cl_directories.dart';
import 'package:flutter/foundation.dart';

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
  final CLDirectories directories;
  final bool shouldValidate;

  String validPrefix(int collectionID) => directories.media.pathString;

  String validRelativePrefix(int collectionID) =>
      '${directories.media.name}/cluster_$collectionID';

  String dbName = 'keepIt.db';
}
