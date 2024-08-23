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

  String validPrefix() => directories.media.pathString;

  String get dbName => 'keepIt.db';

  String mediaSubDirectory({String identfier = 'local'}) {
    final String mediaPath;
    mediaPath = path_handler.join(
      directories.media.pathString,
      identfier,
    );
    return path_handler.relative(
      mediaPath,
      from: directories.persistent.path,
    );
  }
}
