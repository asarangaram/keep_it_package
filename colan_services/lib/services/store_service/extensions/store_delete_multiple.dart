import 'package:store/store.dart';

import '../../store_service/store_service.dart';

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
      await deleteMedia(m);
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

    await removeMultipleMediaFromGallery(
      pinnedMedia,
    );

    for (final m in mediaMultiple) {
      await store.upsertMedia(m.removePin().copyWith(isDeleted: true));
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
