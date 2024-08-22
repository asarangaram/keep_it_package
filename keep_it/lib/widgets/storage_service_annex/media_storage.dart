import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

@immutable
class MediaStorage {
  const MediaStorage({
    required this.previewPath,
    required this.mediaPath,
    required this.originalMediaPath,
  });
  final AsyncValue<String> previewPath;
  final AsyncValue<String> mediaPath;
  final AsyncValue<String> originalMediaPath;
}

class MediaStorageNotifier
    extends FamilyAsyncNotifier<Stream<MediaStorage>, CLMedia> {
  final controller = StreamController<MediaStorage>();

  @override
  FutureOr<Stream<MediaStorage>> build(CLMedia arg) async {
    controller.add(
      const MediaStorage(
        previewPath: AsyncLoading(),
        mediaPath: AsyncLoading(),
        originalMediaPath: AsyncLoading(),
      ),
    );

    return controller.stream;
  }
}

final mediaStorageProvider = AsyncNotifierProviderFamily<MediaStorageNotifier,
    Stream<MediaStorage>, CLMedia>(
  MediaStorageNotifier.new,
);
