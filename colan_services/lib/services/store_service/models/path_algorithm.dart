import 'dart:async';
import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import 'thumbnail_services.dart';
import 'media_storage.dart';

// TODO(anandas): This should be variable and determined
// differently for mobile platforms
int thumbnailDimension = 640;

class MediaPathAlgorithm {
  MediaPathAlgorithm(
    this.media,
    this.appSettings,
    this.thumbnailServiceFuture,
  ) {
    controller = StreamController<MediaStorage>();
  }

  final CLMedia media;
  final AppSettings appSettings;
  final Future<ThumbnailService> thumbnailServiceFuture;
  late final StreamController<MediaStorage> controller;
  MediaStorage _currStorage = MediaStorage.asyncLoading();

  MediaStorage get currStorage => _currStorage;

  set currStorage(MediaStorage value) {
    _currStorage = value;
    print(_currStorage);
    controller.add(_currStorage);
  }

  AsyncValue<Uri> getLocalmediaPath(CLMedia media) {
    try {
      final fPath = path_handler.join(
        appSettings.directories.media.path.path,
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
      appSettings.directories.media.path.path,
      media.name,
    );
    final fpreviewPath = path_handler.join(
      appSettings.directories.thumbnail.pathString,
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
    currStorage = MediaStorage.asyncLoading();

    if (media.serverUID == null) {
      // Check if original Media is available
      final path = getLocalmediaPath(media);
      if (path.hasError) {
        currStorage = MediaStorage.asyncError(
          path.asError!.error,
          path.asError!.stackTrace,
        );
      } else {
        currStorage = MediaStorage(
          mediaPath: path,
          originalMediaPath: path,
        );

        final previewPath = await getLocalpreviewPath(media);
        currStorage = currStorage.copyWith(previewPath: previewPath);
      }
    }
  }

  Stream<MediaStorage> stream() async* {
    currStorage = MediaStorage.asyncLoading();
    unawaited(algo());
    yield* controller.stream;
  }
}
