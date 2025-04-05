import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../db_service/providers/store_query_result.dart';
import '../../db_service/providers/store_updater.dart';

import 'media_path.dart';

final mediaUriProvider = StreamProvider.family<Uri, int>((ref, id) async* {
  final controller = StreamController<Uri>();
  final theStore = await ref.watch(storeUpdaterProvider.future);
  final mediaPathDeterminer =
      await ref.watch(mediaPathDeterminerProvider.future);

  ref.listen(refreshReaderProvider, (prev, curr) async {
    if (prev != curr) {
      final media = await theStore.get(EntityQuery({'id': id}));
      /* log(
        'media : ${media.md5String}',
        name: 'mediaUriProvider',
      ); */
      if (media == null) {
        throw Exception('media not found!');
      }

      controller.add(mediaPathDeterminer.getPreviewUri(media));
    }
  });
  final media = await theStore.get(EntityQuery({'id': id}));
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
      final media = await theStore.get(EntityQuery({'id': id}));
      if (media != null) {
        /* log(
          'media : ${media.md5String}',
          name: 'previewUriProvider',
        ); */

        controller.add(mediaPathDeterminer.getPreviewUri(media));
      } else {}
    }
  });
  final media = await theStore.get(EntityQuery({'id': id}));
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
