/* import 'dart:async';
import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import '../extensions/download_settings.dart';
import '../extensions/media_server_info.dart';
import 'media_files_uri.dart';
import 'thumbnail_services.dart';

class MediaUriDeterminer {
  MediaUriDeterminer(
    this.media, {
    required this.mediaServerInfo,
    required this.appSettings,
    required this.thumbnailService,
    required this.servers,
  }) {
    controller = StreamController<MediaFilesUri>();
  }

  final CLMedia media;
  final MediaServerInfo? mediaServerInfo;
  final AppSettings appSettings;
  final ThumbnailService thumbnailService;
  final Servers servers;
  late final StreamController<MediaFilesUri> controller;
  MediaFilesUri _currStorage = MediaFilesUri.asyncLoading();

  MediaFilesUri get currStorage => _currStorage;

  set currStorage(MediaFilesUri value) {
    _currStorage = value;
    controller.add(_currStorage);
  }

  Future<AsyncValue<Uri>> getLocalmediaPath(CLMedia media) async {
    try {
      final fPath = path_handler.join(
        appSettings.mediaBaseDirectory,
        appSettings.mediaSubDirectoryPath(),
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
      appSettings.mediaBaseDirectory,
      appSettings.mediaSubDirectoryPath(),
      media.name,
    );
    final fpreviewPath = path_handler.join(
      appSettings.mediaBaseDirectory,
      appSettings.mediaSubDirectoryPath(),
      '${media.md5String}.tn.jpeg',
    );
    if (!File(fpreviewPath).existsSync()) {
      // Need to send 'try generating preview'
      final downloadSettings = await StoreExtOnDownloadSettings.load();

      await thumbnailService.createThumbnail(
        info: ThumbnailServiceDataIn(
          uuid: media.md5String!,
          path: fPath,
          thumbnailPath: fpreviewPath,
          isVideo: media.type == CLMediaType.video,
          dimension: downloadSettings.previewDimension,
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

    if (mediaServerInfo == null) {
      final path = await getLocalmediaPath(media);
      final previewPath = await getLocalpreviewPath(media);
      currStorage = MediaFilesUri(
        previewPath: previewPath,
        mediaPath: path,
        originalMediaPath: path,
      );
    } else {
      mediaServerInfo!.getMediaFilesUri(
        baseDirectory: appSettings.mediaBaseDirectory,
        mediaSubDirectory: appSettings.mediaSubDirectoryPath(
          identfier: servers.myServer!.identifier,
        ),
        onGetURI: (endPoint) =>
            servers.myServer!.getEndpointURI(endPoint).toString(),
      );
    }
  }

  static Stream<MediaFilesUri> stream(
    CLMedia media, {
    required Future<MediaServerInfo?> futureMediaServerInfo,
    required Future<AppSettings> futureAppSettings,
    required Future<ThumbnailService> futureThumbnailService,
    required Servers servers,
  }) async* {
    yield MediaFilesUri.asyncLoading();

    final mediaServerInfo = await futureMediaServerInfo;
    final appSettings = await futureAppSettings;
    final thumnailService = await futureThumbnailService;

    final pathAlgo = MediaUriDeterminer(
      media,
      mediaServerInfo: mediaServerInfo,
      appSettings: appSettings,
      thumbnailService: thumnailService,
      servers: servers,
    );

    unawaited(pathAlgo.algo());
    yield* pathAlgo.controller.stream;
  }
}
 */
