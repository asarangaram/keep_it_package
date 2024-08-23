import 'dart:async';

import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../online_service/providers/servers.dart';
import '../models/media_files_uri.dart';
import '../models/path_algorithm.dart';
import 'thumbnail_services.dart';

final mediaStorageProvider =
    StreamProvider.family.autoDispose<MediaFilesUri, CLMedia>((ref, media) {
  StreamSubscription<MediaFilesUri>? subscription;
  final controller = StreamController<MediaFilesUri>();

  final appSettingsFuture = ref.watch(appSettingsProvider.future);
  final thumbnailServiceFuture = ref.watch(thumbnailServiceProvider.future);

  final servers = ref.watch(serversProvider);
  subscription = MediaPathAlgorithm(
    media,
    appSettingsFuture: appSettingsFuture,
    thumbnailServiceFuture: thumbnailServiceFuture,
    servers: servers,
  ).stream().listen(controller.add);
  ref.onDispose(() {
    subscription?.cancel();
    controller.close();
  });

  return controller.stream;
});
