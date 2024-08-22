import 'dart:async';
import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import '../models/media_storage.dart';

final mediaStorageProvider =
    StreamProvider.family.autoDispose<MediaStorage, CLMedia>((ref, media) {
  final controller = StreamController<MediaStorage>();
  StreamSubscription<MediaStorage>? subscription;

  ref.watch(appSettingsProvider).whenOrNull(
        data: (appSettings) {
          // Cancel previous and listen new
          subscription?.cancel();
          subscription = MediaPathAlgorithm(
            media,
            appSettings,
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

@immutable
class MediaPathAlgorithm {
  const MediaPathAlgorithm(this.media, this.appSettings);

  final CLMedia media;
  final AppSettings appSettings;
  String getLocalmediaPath(CLMedia media) {
    final fPath = path_handler.join(
      appSettings.directories.media.path.path,
      media.name,
    );
    if (!File(fPath).existsSync()) {
      throw Exception('File not found');
    }

    return fPath;
  }

  Stream<MediaStorage> stream() async* {
    yield MediaStorage.asyncLoading();
    if (media.serverUID == null) {
      yield MediaStorage(
        previewPath: AsyncData(getLocalmediaPath(media)),
        mediaPath: AsyncData(getLocalmediaPath(media)),
        originalMediaPath: AsyncData(getLocalmediaPath(media)),
      );
    }
  }
}
