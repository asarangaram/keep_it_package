import 'dart:async';

import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'thumbnail_services.dart';
import '../models/media_storage.dart';
import '../models/path_algorithm.dart';

final mediaStorageProvider =
    StreamProvider.family.autoDispose<MediaStorage, CLMedia>((ref, media) {
  final controller = StreamController<MediaStorage>();
  StreamSubscription<MediaStorage>? subscription;
  final serviceFuture = ref.watch(thumbnailServiceProvider.future);
  ref.watch(appSettingsProvider).whenOrNull(
        data: (appSettings) {
          // Cancel previous and listen new
          subscription?.cancel();
          subscription = MediaPathAlgorithm(
            media,
            appSettings,
            serviceFuture,
          ).stream().listen(controller.add);
        },
        loading: () => controller.add(MediaStorage.asyncLoading()),
        error: (e, st) => controller.add(MediaStorage.asyncError(e, st)),
      );
  ref.onDispose(() {
    subscription?.cancel();
    controller.close();
  });

  return controller.stream;
});
