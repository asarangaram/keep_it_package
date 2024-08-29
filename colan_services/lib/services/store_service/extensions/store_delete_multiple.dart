import 'dart:io';

import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import '../models/store_manager.dart';
import 'store_gallery.dart';

extension DeleteMultipleExtOnStoreManager on StoreManager {
  Future<bool> permanentlyDeleteMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final pinnedMedia =
        mediaMultiple.where((e) => e.pin != null).map((e) => e.pin!).toList();
    // Remove Pins first..
    await removeMultipleMediaFromGallery(
      pinnedMedia,
    );

    for (final m in mediaMultiple) {
      await store.deleteMedia(m, permanent: true);
      await File(
        path_handler.join(
          appSettings.directories.media.pathString,
          m.name,
        ),
      ).deleteIfExists();
    }

    return true;
  }

  Future<bool> deleteMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    // Remove Pins first..
    final pinnedMedia =
        mediaMultiple.where((e) => e.pin != null).map((e) => e.pin!).toList();
    // Remove Pins first..
    await removeMultipleMediaFromGallery(
      pinnedMedia,
    );

    for (final m in mediaMultiple) {
      await store.deleteMedia(m, permanent: false);
    }
    return true;
  }

  Future<bool> restoreMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    for (final item in mediaMultiple) {
      if (item.id != null) {
        await store.upsertMedia(item.copyWith(isDeleted: false));
      }
    }
    return true;
  }
}
