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
class MediaInfo2 {
  final CLDirectories directories;
  final List<CLMedia> mediaList;
  final CLServer? server;
  const MediaInfo2({
    required this.directories,
    required this.mediaList,
    required this.server,
  });

  MediaInfo2 copyWith({
    CLDirectories? directories,
    List<CLMedia>? mediaList,
    ValueGetter<CLServer?>? server,
  }) {
    return MediaInfo2(
      directories: directories ?? this.directories,
      mediaList: mediaList ?? this.mediaList,
      server: server != null ? server.call() : this.server,
    );
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'MediaInfo(directories: $directories, media: $mediaList, server: $server)';

  @override
  bool operator ==(covariant MediaInfo2 other) {
    if (identical(this, other)) return true;

    return other.directories == directories &&
        other.mediaList == mediaList &&
        other.server == server;
  }

  @override
  int get hashCode =>
      directories.hashCode ^ mediaList.hashCode ^ server.hashCode;

  //////////////////////////////////////////////////////////////////////////////
  Iterable<CLMedia> get validMedia {
    final iterable =
        mediaList.where((e) => !(e.isDeleted ?? false) && e.mediaLog == null);

    return iterable.where(
      (e) =>
          e.isPreviewLocallyAvailable ||
          (e.isPreviewWaitingForDownload && server != null),
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  String getText(int id) {
    final media = mediaList.where((e) => e.id == id).firstOrNull;

    if (media?.type != CLMediaType.text) return '';
    final uri = Uri.file(getMediaAbsolutePath(media!));
    if (uri.scheme == 'file') {
      final path = uri.toFilePath();

      return File(path).existsSync()
          ? File(path).readAsStringSync()
          : 'Content Missing. File not found';
    }
    throw UnimplementedError('Implement for Server');
  }

  AsyncValue<Uri> getPreviewUriAsync(int id) {
    final media = mediaList.where((e) => e.id == id).firstOrNull;
    final flag = allowOnlineViewIfNotDownloaded;

    try {
      return switch (media) {
        (final CLMedia m) when media.isPreviewLocallyAvailable =>
          AsyncValue.data(Uri.file(getPreviewAbsolutePath(m))),
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

  AsyncValue<Uri> getMediaUriAsync(int id) {
    final media = mediaList.where((e) => e.id == id).firstOrNull;
    try {
      return switch (media) {
        (final CLMedia m) when media.isMediaLocallyAvailable =>
          AsyncValue.data(Uri.file(getMediaAbsolutePath(m))),
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

  String getPreviewAbsolutePath(CLMedia media) => p.join(
        directories.thumbnail.pathString,
        media.previewFileName,
      );

  String getMediaAbsolutePath(CLMedia media) => p.join(
        directories.media.path.path,
        media.mediaFileName,
      );
}

final validMediaProvider = StreamProvider<MediaInfo2?>((ref) async* {
  const mediaQuery = DBQueries.validMedia;
  final controller = StreamController<MediaInfo2?>();

  ref.watch(mediaProvider(mediaQuery)).whenData(controller.add);
  yield* controller.stream;
});

final mediaProvider =
    StreamProvider.family<MediaInfo2?, DBQueries>((ref, query) async* {
  final controller = StreamController<MediaInfo2?>();

  final directories = await ref.watch(deviceDirectoriesProvider.future);
  final store = await ref.watch(storeProvider.future);
  final server = ref.watch(registeredServerProvider);
  final q = store.reader.getQuery(query) as StoreQuery<CLMedia>;

  ref.watch(dbReaderProvider(q)).whenData((data) {
    final mediaList =
        data.where((e) => e != null).map((e) => e as CLMedia).toList();

    controller.add(
      MediaInfo2(
        directories: directories,
        mediaList: mediaList,
        server: server,
      ),
    );
  });

  yield* controller.stream;
});
