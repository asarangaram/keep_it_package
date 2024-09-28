import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db_service/providers/store_updater.dart';

import 'media_path.dart';

final mediaUriProvider =
    FutureProvider.family<AsyncValue<Uri>, int>((ref, id) async {
  final storeAsync = ref.watch(storeUpdaterProvider);

  final mediaPathDeterminer =
      await ref.watch(mediaPathDeterminerProvider.future);
  final noData = storeAsync.when(
    loading: AsyncValue<Uri>.loading,
    error: AsyncValue<Uri>.error,
    data: (_) => null,
  );
  if (noData != null) return noData;
  final theStore = storeAsync.whenOrNull(data: (data) => data)!;
  try {
    final media = await theStore.store.reader.getMediaById(id);
    if (media == null) {
      throw Exception('media not found!');
    }

    return mediaPathDeterminer.getMediaUriAsync(media);
  } catch (error, stackTrace) {
    return AsyncValue.error(error, stackTrace);
  }
});

final previewUriProvider =
    FutureProvider.family<AsyncValue<Uri>, int>((ref, id) async {
  final storeAsync = ref.watch(storeUpdaterProvider);
  final mediaPathDeterminer =
      await ref.watch(mediaPathDeterminerProvider.future);

  final noData = storeAsync.when(
    loading: AsyncValue<Uri>.loading,
    error: AsyncValue<Uri>.error,
    data: (_) => null,
  );
  if (noData != null) return noData;
  final theStore = storeAsync.whenOrNull(data: (data) => data)!;
  try {
    final media = await theStore.store.reader.getMediaById(id);
    if (media == null) {
      throw Exception('media not found!');
    }
    return mediaPathDeterminer.getPreviewUriAsync(media);
  } catch (error, stackTrace) {
    return AsyncValue.error(error, stackTrace);
  }
});
