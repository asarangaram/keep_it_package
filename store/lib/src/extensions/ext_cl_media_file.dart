import 'dart:io';

import 'package:store/extensions.dart';

import '../models/cl_media_file.dart';

extension ExtCLMediaFile on CLMediaFile {
  Future<void> deleteFile() async {
    await File(path).deleteIfExists();
  }
}
