import 'dart:io';

import 'package:colan_widgets/src/models/cl_media/extensions/url_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path_handler;

import '../../../app_logger.dart';
import '../../cl_media.dart';
import '../../cl_media_type.dart';

extension IOExtOnCLMedia on CLMedia {
  void deleteFile() {
    if (File(path).existsSync()) {
      File(path).deleteSync();
    }
  }

  String get basename => path_handler.basename(path);

  Future<CLMedia> download(
    String url,
    CLMediaType type, {
    required String downloadDir,
  }) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return this;

    final targetFile =
        path_handler.join(downloadDir, await URLHandler.generateFileName(url));
    await URLHandler.download(url, targetFile);
    return copyWith(path: targetFile, type: type);
  }

  bool get isValidMedia {
    if (collectionId == null) {
      throw Exception("Item can't be stored without collectionId");
    }
    switch (type) {
      case CLMediaType.image:
      case CLMediaType.video:
      case CLMediaType.audio:
      case CLMediaType.file:
        if (!File(path).existsSync()) {
          return false;
        }

      case CLMediaType.url:
      case CLMediaType.text:
        break;
    }
    return true;
  }

  Future<CLMedia> moveFile({required String pathPrefix}) async {
    if (collectionId == null) {
      throw Exception("Item can't be stored without collectionId");
    }
    final targetDir = path_handler.join(
      pathPrefix,
      'keep_it',
      'cluster_${collectionId!}',
    );
    switch (type) {
      case CLMediaType.image:
      case CLMediaType.video:
      case CLMediaType.audio:
      case CLMediaType.file:
        if (!File(path).existsSync()) {
          throw Exception('Incoming file not found!');
        } else {
          final targetFile =
              path_handler.join(targetDir, path_handler.basename(path));
          if (path != targetFile) {
            File(targetFile).createSync(recursive: true);
            File(path).copySync(targetFile);
            deleteFile();
          }
          return copyWith(path: targetFile);
        }

      case CLMediaType.url:
      case CLMediaType.text:
        return this;
    }
  }
}

bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
