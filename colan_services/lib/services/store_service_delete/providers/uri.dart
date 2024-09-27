import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'store_cache.dart';

final mediaUriProvider = Provider.family<AsyncValue<Uri>, int>((ref, id) {
  final storeAsync = ref.watch(storeCacheProvider);

  return storeAsync.when<AsyncValue<Uri>>(
    loading: AsyncValue<Uri>.loading,
    error: AsyncValue.error,
    data: (theStore) {
      try {
        final media = theStore.getMediaById(id);
        if (media == null) {
          throw Exception('media not found!');
        }
        return theStore.getMediaUriAsync(media);
      } catch (error, stackTrace) {
        return AsyncValue.error(error, stackTrace);
      }
    },
  );
});

final previewUriProvider = Provider.family<AsyncValue<Uri>, int>((ref, id) {
  final storeAsync = ref.watch(storeCacheProvider);

  return storeAsync.when<AsyncValue<Uri>>(
    loading: AsyncValue<Uri>.loading,
    error: AsyncValue.error,
    data: (theStore) {
      try {
        final media = theStore.getMediaById(id);
        if (media == null) {
          throw Exception('media not found!');
        }
        return theStore.getPreviewUriAsync(media);
      } catch (error, stackTrace) {
        return AsyncValue.error(error, stackTrace);
      }
    },
  );
});
