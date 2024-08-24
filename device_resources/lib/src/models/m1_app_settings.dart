import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path_handler;

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

  String get mediaBaseDirectory => directories.persistent.path;

  String mediaSubDirectoryPath({String identfier = 'local'}) =>
      path_handler.relative(
        mediaDirectoryPath(identfier: identfier),
        from: directories.persistent.path,
      );
  String mediaDirectoryPath({String identfier = 'local'}) {
    return path_handler.join(
      directories.media.pathString,
      identfier,
    );
  }

  Directory mediaDirectory({String identfier = 'local'}) =>
      Directory(mediaDirectoryPath(identfier: identfier));
}
