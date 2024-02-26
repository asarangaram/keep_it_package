import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:store/src/store/models/device_directories.dart';

import 'cl_media.dart';

@immutable
class Resources {
  const Resources({required this.directories, required this.db});
  final Database db;
  final DeviceDirectories directories;
  Future<CLMedia?> getMediaByMD5(
    String md5String,
  ) async =>
      CLMediaDB.getByMD5(
        db,
        md5String,
        pathPrefix: directories.docDir.path,
      );
}
