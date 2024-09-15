import 'package:flutter/foundation.dart';

@immutable
class DownloadRequest {
  const DownloadRequest(
    this.uuid, {
    required this.url,
    required this.targetFilename,
    this.onDone,
    this.onError,
    this.forceDownload = false,
  });
  final String uuid;
  final String url;
  final String targetFilename;

  final bool forceDownload;
  final Future<void> Function()? onDone;
  final Future<void> Function(String errorLog)? onError;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadRequest &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          targetFilename == other.targetFilename;

  @override
  int get hashCode => url.hashCode ^ targetFilename.hashCode;
}
