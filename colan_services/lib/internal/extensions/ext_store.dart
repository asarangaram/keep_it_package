import 'package:colan_services/internal/extensions/list.dart';
import 'package:store/store.dart';

import 'ext_cl_medias.dart';

extension StoreExt on Store {
  Future<CLMedias> updateStoreFromMediaMapList(List<dynamic> mediaMap) async {
    final mediaUpdates = await StoreExtCLMedias.mediasFromServerList(
      mediaMap,
      onGetCollectionByLabel: createCollectionIfMissing,
      onGetMedia: getMedia,
    );
    final updatesFromServer = <CLMedia>[];
    for (final m in mediaUpdates.entries) {
      final bool mediaFileChanged;
      final CLMedia? currMedia;
      if (m.id != null) {
        currMedia = await getMediaById(m.id!);
        mediaFileChanged = (currMedia?.md5String != m.md5String);
      } else {
        mediaFileChanged = false;
        currMedia = null;
      }
      final CLMedia? mediaInDB;
      if (currMedia != m) {
        if ((currMedia?.isEdited ?? false) || (currMedia?.isDeleted ?? false)) {
          // Editted and deleted media will be dealt by uploader or conflict
          // resolver. Downloader skips
          mediaInDB = null;
        } else {
          if (mediaFileChanged) {
            mediaInDB = await upsertMedia(
              m.copyWith(isPreviewCached: false, isMediaCached: false),
            );
            await deleteMedia(currMedia!);
          } else {
            mediaInDB = await upsertMedia(m);
          }
        }
      } else {
        mediaInDB = currMedia;
      }

      if (mediaInDB != null) {
        updatesFromServer.add(mediaInDB);
      }
    }
    return CLMedias(updatesFromServer);
  }

  Future<CLMedia?> getMedia({
    int? id,
    int? serverUID,
    String? md5String,
  }) async {
    CLMedia? media;
    if (id != null) {
      media = await getMediaById(id);
      if (media != null) return media;
    }
    if (serverUID != null) {
      media = await getMediaByServerUID(serverUID);
      if (media != null) return media;
    }
    if (md5String != null) {
      media = await getMediaByMD5String(md5String);
      if (media != null) return media;
    }
    return null;
  }

  Future<Collection> createCollectionIfMissing(String label) async {
    return (await getCollectionByLabel(label)) ??
        await upsertCollection(Collection(label: label));
  }

  Future<List<CLMedia>> get checkDBForPreviewDownloadPending async {
    final q = getQuery(
      DBQueries.previewDownloadPending,
    ) as StoreQuery<CLMedia>;
    return (await readMultiple(q)).nonNullableList;
  }

  Future<List<CLMedia>> get checkDBForMediaDownloadPending async {
    final q = getQuery(
      DBQueries.mediaDownloadPending,
    ) as StoreQuery<CLMedia>;
    return (await readMultiple(q)).nonNullableList;
  }
}
