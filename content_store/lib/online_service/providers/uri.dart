import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../extensions/ext_cl_media.dart';
import '../../extensions/ext_cldirectories.dart';
import '../models/cl_server.dart';
import 'server.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import '../../db_service/providers/store_updater.dart';

bool allowOnlineViewIfNotDownloaded = false;
AsyncValue<Uri> getPreviewUriAsync(
  CLMedia media,
  CLDirectories directories,
  CLServer? server,
) {
  final flag = allowOnlineViewIfNotDownloaded;

  try {
    return switch (media) {
      (final CLMedia m) when media.isPreviewLocallyAvailable =>
        AsyncValue.data(Uri.file(directories.getPreviewAbsolutePath(m))),
      (final CLMedia m) when media.isPreviewDownloadFailed =>
        throw Exception(m.previewLog),
      (final CLMedia m) when media.isPreviewWaitingForDownload =>
        flag && m.previewEndPoint != null && server != null
            ? AsyncValue.data(
                Uri.parse(
                  server.getEndpointURI(m.previewEndPoint!).toString(),
                ),
              )
            : const AsyncValue<Uri>.loading(),
      _ => throw UnimplementedError()
    };
  } catch (error, stackTrace) {
    return AsyncError(error, stackTrace);
  }
}

AsyncValue<Uri> getMediaUriAsync(
  CLMedia media,
  CLDirectories directories,
  CLServer? server,
) {
  try {
    return switch (media) {
      (final CLMedia m) when media.isMediaLocallyAvailable =>
        AsyncValue.data(Uri.file(directories.getMediaAbsolutePath(m))),
      (final CLMedia m) when media.isMediaDownloadFailed =>
        throw Exception(m.mediaLog),
      (final CLMedia m) when !media.haveItOffline =>
        server != null && m.mediaEndPoint != null
            ? AsyncValue.data(
                Uri.parse(
                  server.getEndpointURI(m.mediaEndPoint!).toString(),
                ),
              )
            : throw Exception('Server Not connected'),
      (final CLMedia _) when media.isMediaWaitingForDownload =>
        const AsyncValue<Uri>.loading(),
      _ => throw UnimplementedError()
    };
  } catch (error, stackTrace) {
    return AsyncError(error, stackTrace);
  }
}

final mediaUriProvider =
    FutureProvider.family<AsyncValue<Uri>, int>((ref, id) async {
  final storeAsync = ref.watch(storeUpdaterProvider);
  final directories = await ref.watch(deviceDirectoriesProvider.future);
  final server = ref.watch(serverProvider);
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
    return getMediaUriAsync(media, directories, server.identity);
  } catch (error, stackTrace) {
    return AsyncValue.error(error, stackTrace);
  }
});

final previewUriProvider =
    FutureProvider.family<AsyncValue<Uri>, int>((ref, id) async {
  final storeAsync = ref.watch(storeUpdaterProvider);
  final directories = await ref.watch(deviceDirectoriesProvider.future);
  final server = ref.watch(serverProvider);

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
    return getPreviewUriAsync(media, directories, server.identity);
  } catch (error, stackTrace) {
    return AsyncValue.error(error, stackTrace);
  }
});
