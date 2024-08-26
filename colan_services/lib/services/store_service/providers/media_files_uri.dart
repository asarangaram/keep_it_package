/* import 'dart:async';
import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import '../../online_service/providers/servers.dart';
import '../extensions/download_settings.dart';

import '../models/thumbnail_services.dart';

import 'store.dart';
import 'thumbnail_services.dart';

final mediaFilesUriProvider = StateNotifierProvider.family<MFUriNotifier,
    AsyncValue<MediaFilesUri>, CLMedia>((ref, media) {
  final futureAppSettings = ref.watch(appSettingsProvider.future);
  final futureThumbnailService = ref.watch(thumbnailServiceProvider.future);
  final servers = ref.watch(serversProvider);
  final futureStore = ref.watch(storeProvider.future);

  final notifier = MFUriNotifier(
    media,
    futureAppSettings: futureAppSettings,
    futureThumbnailService: futureThumbnailService,
    futureStore: futureStore,
    servers: servers,
  );

  return notifier;
});

class MFUriNotifier extends StateNotifier<AsyncValue<MediaFilesUri>> {
  MFUriNotifier(
    this.media, {
    required this.futureAppSettings,
    required this.futureThumbnailService,
    required this.futureStore,
    required this.servers,
  }) : super(const AsyncValue.loading()) {
    determine();
  }

  CLMedia media;

  Future<AppSettings> futureAppSettings;
  Future<ThumbnailService> futureThumbnailService;
  Future<Store> futureStore;
  Servers servers;

  MediaFilesUri? _stateData;

  @override
  String toString() => '(${media.hashCode} '
      '${futureAppSettings.hashCode} ${futureThumbnailService.hashCode} '
      '${servers.hashCode})';

  Future<void> updateState(MediaFilesUri value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _stateData = value;
    });
  }

  Future<void> determine() async {
    _infoLogger(state.toString());
    final store = await futureStore;

    final appSettings = await futureAppSettings;

    final query = store.getQuery(
      DBQueries.serverMediaMetaDataById,
      parameters: [media.id],
    ) as StoreQuery<ServerMediaLocalStateInfo>;

    final mediaServerInfo = await store.read(query);

    if (mediaServerInfo == null) {
      final path = await getLocalmediaPath(media);
      final Uri? previewPath;
      if (path != null) {
        previewPath = await getLocalpreviewPath(media);
      } else {
        previewPath = null;
      }

      await updateState(
        MediaFilesUri(
          previewPath: previewPath,
          mediaPath: path,
          originalMediaPath: path,
        ),
      );
    } else {
      await updateState(
        mediaServerInfo.getMediaFilesUri(
          baseDirectory: appSettings.mediaBaseDirectory,
          mediaSubDirectory: appSettings.mediaSubDirectoryPath(
            identfier: servers.myServer!.identifier,
          ),
          onGetURI: (endPoint) =>
              servers.myServer!.getEndpointURI(endPoint).toString(),
        ),
      );
    }
  }

  Future<Uri?> getLocalmediaPath(CLMedia media) async {
    final appSettings = await futureAppSettings;
    try {
      final fPath = path_handler.join(
        appSettings.mediaBaseDirectory,
        appSettings.mediaSubDirectoryPath(),
        media.name,
      );
      if (!File(fPath).existsSync()) {
        throw Exception('file not found');
      }
      return Uri.file(fPath);
    } catch (error) {
      return null;
    }
  }

  Future<Uri?> getLocalpreviewPath(CLMedia media) async {
    final thumbnailService = await futureThumbnailService;
    final appSettings = await futureAppSettings;
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
    if (!File(fPath).existsSync()) {
      return null;
    }
    if (File(fpreviewPath).existsSync()) {
      return Uri.file(fpreviewPath);
    }
    {
      final downloadSettings = await StoreExtOnDownloadSettings.load();

      unawaited(
        thumbnailService.createThumbnail(
          info: ThumbnailServiceDataIn(
            uuid: media.md5String!,
            path: fPath,
            thumbnailPath: fpreviewPath,
            isVideo: media.type == CLMediaType.video,
            dimension: downloadSettings.previewDimension,
          ),
          onError: (errorString) async {
            try {
              throw Exception(errorString);
            } catch (error) {
              await updateState(
                MediaFilesUri(
                  previewPath: null,
                  mediaPath: _stateData?.mediaPath,
                  originalMediaPath: _stateData?.originalMediaPath,
                ),
              );
            }
          },
          onData: () async {
            try {
              if (!File(fpreviewPath).existsSync()) {
                throw Exception('unable to create thumbnail');
              }
              await updateState(
                MediaFilesUri(
                  previewPath: Uri.file(fpreviewPath),
                  mediaPath: _stateData?.mediaPath,
                  originalMediaPath: _stateData?.originalMediaPath,
                ),
              );
            } catch (error) {
              await updateState(
                MediaFilesUri(
                  previewPath: null,
                  mediaPath: _stateData?.mediaPath,
                  originalMediaPath: _stateData?.originalMediaPath,
                ),
              );
            }
          },
        ),
      );
    }
    return null;
  }
}

const _filePrefix = 'MFUriNotifier: ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
 */
