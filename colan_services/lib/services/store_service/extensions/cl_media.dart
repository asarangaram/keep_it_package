import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:path/path.dart' as path_handler;

import 'package:store/store.dart';

extension MediaUriOnCLMedia on CLMedia {
  String get mediaFilename => '$id$fExt';
  String get previewFilename => '$id.tn$fExt';

  Uri returnValidPath(Uri p) {
    if (p.scheme != 'file') {
      throw Exception('Uri is not referrring to a file');
    }
    if (!File(p.path).parent.existsSync()) {
      File(p.path).parent.createSync(recursive: true);
    }
    return p;
  }

  Uri previewFileURI(AppSettings appSettings) {
    return returnValidPath(
      Uri.file(
        path_handler.join(
          appSettings.dir.thumbnail.pathString,
          previewFilename,
        ),
      ),
    );
  }

  Uri mediaFileURI(AppSettings appSettings) {
    return returnValidPath(
      Uri.file(
        path_handler.join(
          appSettings.dir.media.pathString,
          mediaFilename,
        ),
      ),
    );
  }
}
