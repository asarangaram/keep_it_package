import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media.dart';

final mediaUriProvider = Provider.family<AsyncValue<Uri>, int>((ref, id) {
  final mediaAsync = ref.watch(mediaProvider(id));

  return mediaAsync.when<AsyncValue<Uri>>(
    loading: AsyncValue<Uri>.loading,
    error: AsyncValue.error,
    data: (mediaInfo) {
      try {
        if (mediaInfo == null) {
          throw Exception('media not found!');
        }
        return mediaInfo.getMediaUriAsync();
      } catch (error, stackTrace) {
        return AsyncValue.error(error, stackTrace);
      }
    },
  );
});

final previewUriProvider = Provider.family<AsyncValue<Uri>, int>((ref, id) {
  final mediaAsync = ref.watch(mediaProvider(id));

  return mediaAsync.when<AsyncValue<Uri>>(
    loading: AsyncValue<Uri>.loading,
    error: AsyncValue.error,
    data: (mediaInfo) {
      try {
        if (mediaInfo == null) {
          throw Exception('media not found!');
        }
        return mediaInfo.getPreviewUriAsync();
      } catch (error, stackTrace) {
        return AsyncValue.error(error, stackTrace);
      }
    },
  );
});
