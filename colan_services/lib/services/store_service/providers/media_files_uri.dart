import 'dart:async';

import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../online_service/providers/servers.dart';
import '../models/media_files_uri.dart';
import '../models/path_algorithm.dart';
import 'media_server_info.dart';
import 'thumbnail_services.dart';

final mediaFilesUriProvider =
    StreamProvider.family.autoDispose<MediaFilesUri, CLMedia>((ref, media) {
  StreamSubscription<MediaFilesUri>? subscription;
  final controller = StreamController<MediaFilesUri>();

  final futureAppSettings = ref.watch(appSettingsProvider.future);
  final futureThumbnailService = ref.watch(thumbnailServiceProvider.future);
  final servers = ref.watch(serversProvider);

  final futureMediaServerInfo =
      ref.watch(mediaServerInfoProvider(media).future);

  subscription = MediaUriDeterminer.stream(
    media,
    futureMediaServerInfo: futureMediaServerInfo,
    futureAppSettings: futureAppSettings,
    futureThumbnailService: futureThumbnailService,
    servers: servers,
  ).listen(controller.add);
  ref.onDispose(() {
    subscription?.cancel();
    controller.close();
  });

  return controller.stream;
});
