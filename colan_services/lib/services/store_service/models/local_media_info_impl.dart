import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

@immutable
class LocalMediaInfoImpl extends MediaInfo {
  const LocalMediaInfoImpl(this.media, {required this.appSettings});
  final AppSettings appSettings;
  final CLMedia media;

  String get mediaFilename => '${media.id}.${media.fExt}';

  @override
  Uri get previewURI {
    return returnValidPath(
      Uri.file(
        path_handler.join(
          appSettings.thumbnailDirectoryPath,
          '$mediaFilename.tn',
        ),
      ),
    );
  }

  @override
  Uri get mediaURI {
    return returnValidPath(
      Uri.file(
        path_handler.join(
          appSettings.mediaDirectory.path,
          mediaFilename,
        ),
      ),
    );
  }

  @override

  /// Local Media is always original, no LQ variant is stored ever
  bool get isUriOriginal => true;
}
