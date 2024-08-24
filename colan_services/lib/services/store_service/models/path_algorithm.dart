import 'dart:async';
import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import '../../online_service/models/servers.dart';
import 'media_files_uri.dart';
import 'thumbnail_services.dart';

// TODO(anandas): This should be variable and determined
// differently for mobile platforms
int thumbnailDimension = 640;

class MediaPathAlgorithm {
  MediaPathAlgorithm(
    this.media, {
    required this.appSettingsFuture,
    required this.thumbnailServiceFuture,
    required this.servers,
  }) {
    controller = StreamController<MediaFilesUri>();
  }

  final CLMedia media;
  final Future<AppSettings> appSettingsFuture;
  final Future<ThumbnailService> thumbnailServiceFuture;
  final Servers servers;
  late final StreamController<MediaFilesUri> controller;
  MediaFilesUri _currStorage = MediaFilesUri.asyncLoading();

  MediaFilesUri get currStorage => _currStorage;

  set currStorage(MediaFilesUri value) {
    _currStorage = value;
    controller.add(_currStorage);
  }

  Future<AppSettings> get appSettings async => appSettingsFuture;

  Future<AsyncValue<Uri>> getLocalmediaPath(CLMedia media) async {
    try {
      final fPath = path_handler.join(
        (await appSettings).directories.media.path.path,
        media.name,
      );
      if (!File(fPath).existsSync()) {
        throw Exception('file not found');
      }
      return AsyncData(Uri.file(fPath));
    } catch (error, stackTrace) {
      return AsyncValue<Uri>.error(error, stackTrace);
    }
  }

  Future<AsyncValue<Uri>> getLocalpreviewPath(CLMedia media) async {
    final fPath = path_handler.join(
      (await appSettings).directories.media.path.path,
      media.name,
    );
    final fpreviewPath = path_handler.join(
      (await appSettings).directories.thumbnail.pathString,
      '${media.md5String}.tn.jpeg',
    );
    if (!File(fpreviewPath).existsSync()) {
      // Need to send 'try generating preview'

      final thumbnailService = await thumbnailServiceFuture;

      await thumbnailService.createThumbnail(
        info: ThumbnailServiceDataIn(
          uuid: media.md5String!,
          path: fPath,
          thumbnailPath: fpreviewPath,
          isVideo: media.type == CLMediaType.video,
          dimension: thumbnailDimension,
        ),
        onError: (errorString) {
          try {
            throw Exception(errorString);
          } catch (error, stackTrace) {
            currStorage = currStorage.copyWith(
              previewPath: AsyncError(error, stackTrace),
            );
          }
        },
        onData: () {
          try {
            if (!File(fpreviewPath).existsSync()) {
              throw Exception('unable to create thumbnail');
            }
            currStorage = currStorage.copyWith(
              previewPath: AsyncData(Uri.file(fpreviewPath)),
            );
          } catch (error, stackTrace) {
            currStorage = currStorage.copyWith(
              previewPath: AsyncError(error, stackTrace),
            );
          }
        },
      );

      return const AsyncLoading();
    }

    return AsyncData(Uri.file(fpreviewPath));
  }

  Future<void> algo() async {
    currStorage = MediaFilesUri.asyncLoading();
    // Check if original Media is available
    final path = await getLocalmediaPath(media);
    if (path.hasError) {
      currStorage = MediaFilesUri.asyncError(
        path.asError!.error,
        path.asError!.stackTrace,
      );
    } else {
      currStorage = MediaFilesUri(
        mediaPath: path,
        originalMediaPath: path,
      );

      final previewPath = await getLocalpreviewPath(media);
      currStorage = currStorage.copyWith(previewPath: previewPath);
    }

    /* if (media.serverUID == null) {
      
    } else {
      final myServer = servers.myServer;
      // check for local copy "somehow"
      if (myServer == null) {
        // Local copy not available, return Error
      } else {
        currStorage = currStorage.copyWith(
          previewPath: AsyncData(
            myServer
                .getEndpointURI('/media/${media.serverUID}/download?preview'),
          ),
          mediaPath: AsyncData(
            myServer.getEndpointURI('/media/${media.serverUID}/download'),
          ),
        );
      }
    } */
  }

  Stream<MediaFilesUri> stream() async* {
    currStorage = MediaFilesUri.asyncLoading();
    unawaited(algo());
    yield* controller.stream;
  }
}
