import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_services/services/store_service/models/media_manager.dart';
import 'package:colan_services/services/store_service/providers/store.dart';

import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/thumbnail_services.dart';

import 'c_download_settings.dart';
import 'thumbnail_services.dart';

class MediaManagerNotifier extends StateNotifier<AsyncValue<MediaManager>> {
  MediaManagerNotifier(
    this.ref,
    this.media,
    this.futureAppSettings,
    this.servers,
    this.asyncValueDownloadSettings,
    this.asyncValueThumbnailProvider,
    this.futureStore,
  ) : super(const AsyncValue.loading()) {
    getMediaManager();
  }
  final Ref ref;
  final CLMedia media;
  final Future<AppSettings> futureAppSettings;

  final Servers servers;
  final AsyncValue<DownloadSettings> asyncValueDownloadSettings;
  final AsyncValue<ThumbnailService> asyncValueThumbnailProvider;
  final Future<Store> futureStore;

  Future<void> getMediaManager() async {
    if (media.id == null) return;

    final appSettings = await futureAppSettings;
    final store = await futureStore;
    asyncValueThumbnailProvider.whenOrNull(
      error: (error, stackTrace) => state = AsyncValue.error(error, stackTrace),
      data: (thumbnailService) {
        asyncValueDownloadSettings.whenOrNull(
          error: (error, stackTrace) =>
              state = AsyncValue.error(error, stackTrace),
          data: (downloadSettings) async {
            final localInfo = await _fetch();
            final localInfoManager = MediaManager(
              media: media,
              localInfo: localInfo,
              appSettings: appSettings,
              downloadSettings: downloadSettings,
              server: servers.myServer,
              store: store,
            );

            state = const AsyncValue.loading();
            state = await AsyncValue.guard(() async {
              return localInfoManager;
            });
            unawaited(checkFiles(localInfoManager));
          },
        );
      },
    );
  }

  Future<void> checkFiles(MediaManager localInfoManager) async {}

  Future<MediaLocalInfo> _fetch() async {
    final store = await futureStore;
    final query = store.getQuery(
      DBQueries.localInfoById,
      parameters: [media.id],
    ) as StoreQuery<MediaLocalInfo>;

    return await store.read<MediaLocalInfo>(query) ??
        await store.upsertMediaLocalInfo(
          DefaultMediaLocalInfo(id: media.id!),
        );
  }

  Future<CLMedia> replaceMedia(
    MediaManager mediaManager,
    CLMedia originalMedia,
    String outFile,
  ) async {
    final resultMedia = await mediaManager.replaceMedia(originalMedia, outFile);
    if (resultMedia != mediaManager.media) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return mediaManager.copyWith(media: resultMedia);
      });
    }
    return resultMedia;
  }

  Future<CLMedia> cloneAndReplaceMedia(
    MediaManager mediaManager,
    CLMedia originalMedia,
    String outFile,
  ) {
    final resultMedia =
        mediaManager.cloneAndReplaceMedia(originalMedia, outFile);
    return resultMedia;
  }
}

final mediaManagerProvider = StateNotifierProvider.family<MediaManagerNotifier,
    AsyncValue<MediaManager>, CLMedia>((ref, media) {
  final appSettings = ref.watch(appSettingsProvider.future);

  final servers = ref.watch(serversProvider);
  final downloadSettings = ref.watch(downloadSettingsProvider);
  final thumbnailProvider = ref.watch(thumbnailServiceProvider);
  final store = ref.watch(storeProvider.future);
  return MediaManagerNotifier(
    ref,
    media,
    appSettings,
    servers,
    downloadSettings,
    thumbnailProvider,
    store,
  );
});
