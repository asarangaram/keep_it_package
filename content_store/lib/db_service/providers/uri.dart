import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../extensions/ext_cldirectories.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import 'store_updater.dart';

@immutable
class UriProvider {
  const UriProvider({required this.directories});
  final CLDirectories directories;
  AsyncValue<Uri> getPreviewUriAsync(CLMedia m) {
    return AsyncValue.data(Uri.file(directories.getPreviewAbsolutePath(m)));
  }

  AsyncValue<Uri> getMediaUriAsync(
    CLMedia m,
  ) {
    return AsyncValue.data(Uri.file(directories.getMediaAbsolutePath(m)));
  }
}

final mediaUriProvider =
    FutureProvider.family<AsyncValue<Uri>, int>((ref, id) async {
  final storeAsync = ref.watch(storeUpdaterProvider);
  final directories = await ref.watch(deviceDirectoriesProvider.future);

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
    return UriProvider(directories: directories).getMediaUriAsync(media);
  } catch (error, stackTrace) {
    return AsyncValue.error(error, stackTrace);
  }
});

final previewUriProvider =
    FutureProvider.family<AsyncValue<Uri>, int>((ref, id) async {
  final storeAsync = ref.watch(storeUpdaterProvider);
  final directories = await ref.watch(deviceDirectoriesProvider.future);

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
    return UriProvider(directories: directories).getPreviewUriAsync(media);
  } catch (error, stackTrace) {
    return AsyncValue.error(error, stackTrace);
  }
});
