import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_reader.dart';

final mediaUriProvider = Provider.family<AsyncValue<Uri>, int>((ref, id) {
  final mediaAsync = ref.watch(mediaProvider);

  return mediaAsync.when<AsyncValue<Uri>>(
    loading: AsyncValue<Uri>.loading,
    error: AsyncValue.error,
    data: (mediaInfo) => mediaInfo.getMediaUriAsync(id),
  );
});

final previewUriProvider = Provider.family<AsyncValue<Uri>, int>((ref, id) {
  final mediaAsync = ref.watch(mediaProvider);

  return mediaAsync.when<AsyncValue<Uri>>(
    loading: AsyncValue<Uri>.loading,
    error: AsyncValue.error,
    data: (mediaInfo) => mediaInfo.getPreviewUriAsync(id),
  );
});
