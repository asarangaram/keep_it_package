import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import 'media_storage.dart';

@immutable
class MediaPathAlgorithm {
  const MediaPathAlgorithm(this.media, this.appSettings);

  final CLMedia media;
  final AppSettings appSettings;
  AsyncValue<Uri> getLocalmediaPath(CLMedia media) {
    try {
      final fPath = path_handler.join(
        appSettings.directories.media.path.path,
        media.name,
      );
      if (File(fPath).existsSync()) {
        throw Exception('file not found');
      }
      return AsyncData(Uri.file(fPath));
    } catch (error, stackTrace) {
      return AsyncValue<Uri>.error(error, stackTrace);
    }
  }

  Stream<MediaStorage> stream() async* {
    final storage = MediaStorage.asyncLoading();
    yield storage;
    if (media.serverUID == null) {
      yield storage.copyWith(
        mediaPath: getLocalmediaPath(media),
        originalMediaPath: getLocalmediaPath(media),
      );
    }
  }
}
