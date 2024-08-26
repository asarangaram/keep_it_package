import 'dart:io';

import 'package:meta/meta.dart';

@immutable
abstract class MediaInfo {
  const MediaInfo();

  bool get isUriOriginal;
  Uri get mediaURI;
  Uri get previewURI;

  Uri returnValidPath(Uri p) {
    if (p.scheme != 'file') {
      throw Exception('Uri is not referrring to a file');
    }
    if (!File(p.path).parent.existsSync()) {
      File(p.path).parent.createSync(recursive: true);
    }
    return p;
  }
}

@immutable
abstract class ServerMediaInfo extends MediaInfo {
  const ServerMediaInfo();

  @override
  @mustBeOverridden
  bool get isUriOriginal => throw UnimplementedError();

  @override
  @mustBeOverridden
  Uri get mediaURI => throw UnimplementedError();

  @override
  @mustBeOverridden
  Uri get previewURI => throw UnimplementedError();

  String get mediaURL;
  String get originalURL;
  String get previewURL;
  @override
  Uri returnValidPath(Uri p) {
    if (!File(p.path).parent.existsSync()) {
      File(p.path).parent.createSync(recursive: true);
    }
    return p;
  }
}
