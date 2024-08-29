import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import '../models/store_manager.dart';
import 'store_upsert_all.dart';

extension GalleryExtOnStoreManager on StoreManager {
  Future<bool> togglePinMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.any((e) => e.pin == null)) {
      return pinMediaMultiple(mediaMultiple);
    } else {
      return removePinMediaMultiple(mediaMultiple);
    }
  }

  Future<bool> removeMultipleMediaFromGallery(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return true;
    final res = await albumManager.removeMultipleMedia(ids);
    // Notify?
    return res;
  }

  Future<bool> removePinMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    final res = await removeMultipleMediaFromGallery(
      pinnedMedia.map((e) => e.pin!).toList(),
    );
    if (res) {
      await upsertMediaMultiple(pinnedMedia.map((e) => e.removePin()).toList());
    }
    return res;
  }

  Future<bool> pinMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final updatedMedia = <CLMedia>[];
    for (final media in mediaMultiple) {
      if (media.id != null) {
        final pin = await albumManager.addMedia(
          path_handler.join(
            appSettings.directories.media.pathString,
            media.name,
          ),
          title: media.name,
          isImage: media.type == CLMediaType.image,
          isVideo: media.type == CLMediaType.video,
          desc: 'KeepIT',
        );
        if (pin != null) {
          updatedMedia.add(media.copyWith(pin: pin));
        }
      }
    }
    await upsertMediaMultiple(updatedMedia);
    return true;
  }

  Future<bool> removeMediaFromGallery(
    String ids,
  ) async {
    final res = await albumManager.removeMedia(ids);

    return res;
  }
}
