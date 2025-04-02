import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db_service/providers/db_reader.dart';
import '../../db_service/providers/store_updater.dart';

import 'media_path.dart';

final mediaUriProvider = StreamProvider.family<Uri, int>((ref, id) async* {
  final controller = StreamController<Uri>();
  final theStore = await ref.watch(storeUpdaterProvider.future);
  final mediaPathDeterminer =
      await ref.watch(mediaPathDeterminerProvider.future);

  ref.listen(refreshReaderProvider, (prev, curr) async {
    if (prev != curr) {
      final media = await theStore.store.reader.getMediaById(id);
      if (media != null) {
        /* log(
          'media : ${media.md5String}',
          name: 'mediaUriProvider',
        ); */

        controller.add(mediaPathDeterminer.getPreviewUri(media));
      }
    }
  });
  final media = await theStore.store.reader.getMediaById(id);
  if (media == null) {
    throw Exception('media not found!');
  }
  /* log(
    'media : ${media.md5String}',
    name: 'mediaUriProvider',
  ); */
  controller.add(mediaPathDeterminer.getMediaUri(media));
  yield* controller.stream;
});

final previewUriProvider = StreamProvider.family<Uri, int>((ref, id) async* {
  final controller = StreamController<Uri>();
  final theStore = await ref.watch(storeUpdaterProvider.future);
  final mediaPathDeterminer =
      await ref.watch(mediaPathDeterminerProvider.future);

  ref.listen(refreshReaderProvider, (prev, curr) async {
    if (prev != curr) {
      final media = await theStore.store.reader.getMediaById(id);
      if (media != null) {
        /* log(
          'media : ${media.md5String}',
          name: 'previewUriProvider',
        ); */

        controller.add(mediaPathDeterminer.getPreviewUri(media));
      } else {}
    }
  });
  final media = await theStore.store.reader.getMediaById(id);
  if (media == null) {
    throw Exception('media not found!');
  }
  /* log(
    'media : ${media.md5String}',
    name: 'previewUriProvider',
  ); */
  controller.add(mediaPathDeterminer.getPreviewUri(media));
  yield* controller.stream;
});
