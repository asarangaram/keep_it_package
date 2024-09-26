// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_services/internal/extensions/ext_cl_media.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../colan_service/models/cl_server.dart';
import '../../colan_service/providers/registerred_server.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import 'p3_db_reader.dart';
import 'store.dart';

bool allowOnlineViewIfNotDownloaded = false;

@immutable
class MediaInfo {
  final CLDirectories directories;
  final CLMedia media;
  final CLServer? server;
  const MediaInfo({
    required this.directories,
    required this.media,
    required this.server,
  });

  MediaInfo copyWith({
    CLDirectories? directories,
    CLMedia? media,
    ValueGetter<CLServer?>? server,
  }) {
    return MediaInfo(
      directories: directories ?? this.directories,
      media: media ?? this.media,
      server: server != null ? server.call() : this.server,
    );
  }

  @override
  String toString() =>
      'MediaInfo(directories: $directories, media: $media, server: $server)';

  @override
  bool operator ==(covariant MediaInfo other) {
    if (identical(this, other)) return true;

    return other.directories == directories &&
        other.media == media &&
        other.server == server;
  }

  @override
  int get hashCode => directories.hashCode ^ media.hashCode ^ server.hashCode;

  String getText() {
    if (media.type != CLMediaType.text) return '';
    final uri = getMediaUri();
    if (uri.scheme == 'file') {
      final path = uri.toFilePath();

      return File(path).existsSync()
          ? File(path).readAsStringSync()
          : 'Content Missing. File not found';
    }
    throw UnimplementedError('Implement for Server');
  }

  Uri getPreviewUri() {
    return Uri.file(getPreviewAbsolutePath());
  }

  AsyncValue<Uri> getPreviewUriAsync() {
    final flag = allowOnlineViewIfNotDownloaded;

    try {
      return switch (media) {
        (final CLMedia _) when media.isPreviewLocallyAvailable =>
          AsyncValue.data(Uri.file(getPreviewAbsolutePath())),
        (final CLMedia m) when media.isPreviewDownloadFailed =>
          throw Exception(m.previewLog),
        (final CLMedia m) when media.isPreviewWaitingForDownload => flag
            ? AsyncValue.data(
                Uri.parse(
                  server!
                      .getEndpointURI('/media/${m.serverUID}/preview')
                      .toString(),
                ),
              )
            : const AsyncValue<Uri>.loading(),
        _ => throw UnimplementedError()
      };
    } catch (error, stackTrace) {
      return AsyncError(error, stackTrace);
    }
  }

  AsyncValue<Uri> getMediaUriAsync() {
    try {
      return switch (media) {
        (final CLMedia _) when media.isMediaLocallyAvailable =>
          AsyncValue.data(Uri.file(getMediaAbsolutePath())),
        (final CLMedia m) when media.isMediaDownloadFailed =>
          throw Exception(m.mediaLog),
        (final CLMedia m) when !media.haveItOffline => server != null
            ? AsyncValue.data(
                Uri.parse(
                  server!
                      .getEndpointURI('/media/${m.serverUID}/'
                          'download?isOriginal=${m.mustDownloadOriginal}')
                      .toString(),
                ),
              )
            : throw Exception('Server Not connected'),
        (final CLMedia _) when media.isMediaWaitingForDownload =>
          const AsyncValue<Uri>.loading(),
        _ => throw UnimplementedError()
      };
    } catch (error, stackTrace) {
      return AsyncError(error, stackTrace);
    }
  }

  Uri getMediaUri() {
    return Uri.file(getMediaAbsolutePath());
  }

  String getPreviewAbsolutePath() => p.join(
        directories.thumbnail.pathString,
        media.previewFileName,
      );

  String getMediaAbsolutePath() => p.join(
        directories.media.path.path,
        media.mediaFileName,
      );
}

final mediaProvider = StreamProvider.family<MediaInfo?, int>((ref, id) async* {
  final controller = StreamController<MediaInfo?>();

  final directories = await ref.watch(deviceDirectoriesProvider.future);
  final store = await ref.watch(storeProvider.future);
  final q = store.reader.getQuery(DBQueries.mediaById, parameters: [id])
      as StoreQuery<CLMedia>;
  final server = ref.watch(registeredServerProvider);
  ref.watch(dbReaderProvider(q)).whenData((data) {
    final media = data.firstOrNull as CLMedia?;

    controller.add(
      (media == null)
          ? null
          : MediaInfo(directories: directories, media: media, server: server),
    );
  });

  yield* controller.stream;
});
