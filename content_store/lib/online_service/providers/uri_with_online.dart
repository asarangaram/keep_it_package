import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:server/server.dart';
import 'package:store/store.dart';

import '../../db_service/models/uri.dart';
import '../../extensions/ext_cl_media.dart';
import '../../extensions/ext_cldirectories.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';

@immutable
class MediaPathDeterminerWithOnlineSupport extends MediaPathDeterminer {
  factory MediaPathDeterminerWithOnlineSupport({
    required CLDirectories directories,
    CLServer? server,
  }) {
    return MediaPathDeterminerWithOnlineSupport._(
      directories: directories,
      server: server,
      allowOnlineViewIfNotDownloaded: true,
    );
  }

  const MediaPathDeterminerWithOnlineSupport._({
    required super.directories,
    required this.server,
    required this.allowOnlineViewIfNotDownloaded,
  });
  final CLServer? server;
  final bool allowOnlineViewIfNotDownloaded;

  @override
  AsyncValue<Uri> getPreviewUriAsync(CLMedia m) {
    final flag = allowOnlineViewIfNotDownloaded;
    try {
      return switch (m) {
        (final CLMedia _) when m.isPreviewLocallyAvailable =>
          AsyncValue.data(Uri.file(directories.getPreviewAbsolutePath(m))),
        (final CLMedia _) when m.isPreviewDownloadFailed =>
          throw Exception(m.previewLog),
        (final CLMedia _) when m.isPreviewWaitingForDownload =>
          flag && m.previewEndPoint != null && server != null
              ? AsyncValue.data(
                  Uri.parse(
                    server!.getEndpointURI(m.previewEndPoint!).toString(),
                  ),
                )
              : const AsyncValue<Uri>.loading(),
        _ => throw UnimplementedError()
      };
    } catch (error, stackTrace) {
      return AsyncError(error, stackTrace);
    }
  }

  @override
  AsyncValue<Uri> getMediaUriAsync(CLMedia m) {
    try {
      return switch (m) {
        (final CLMedia _) when m.isMediaLocallyAvailable =>
          AsyncValue.data(Uri.file(directories.getMediaAbsolutePath(m))),
        (final CLMedia _) when m.isMediaDownloadFailed =>
          throw Exception(m.mediaLog),
        (final CLMedia _) when !(m.haveItOffline ?? false) =>
          server != null && m.mediaStreamEndPoint != null
              ? AsyncValue.data(
                  Uri.parse(
                    server!.getEndpointURI(m.mediaStreamEndPoint!).toString(),
                  ),
                )
              : throw Exception('Server Not connected'),
        (final CLMedia _) when m.isMediaWaitingForDownloadINCORRECT =>
          const AsyncValue<Uri>.loading(),
        _ => throw UnimplementedError()
      };
    } catch (error, stackTrace) {
      return AsyncError(error, stackTrace);
    }
  }
}
