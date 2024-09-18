import 'package:mime/mime.dart';
import 'package:store/store.dart';

import 'ext_cl_media.dart';

extension StoreExtCLMedias on CLMedias {
  static Future<CLMedias> mediasFromServerList(
    List<dynamic> mediaMap, {
    required Future<Collection> Function(String label) onGetCollectionByLabel,
    required Future<CLMedia?> Function({
      int? id,
      int? serverUID,
      String? md5String,
    }) onGetMedia,
  }) async {
    final updatesFromServer = <CLMedia>[];
    final allFromServer = <CLMedia>[];
    for (final m in mediaMap) {
      final map = m as Map<String, dynamic>;

      /// IF fExt is not present, try updating from content_type
      /// For normal scenario, this will be good, for cases where
      /// extension is not available, we may end up with mime back
      /// Current version is not handling it assuming all media we recognized
      /// in this module has valid extension from mime. [KNOWN_ISSUE]
      map['fExt'] ??= '.${extensionFromMime(map['content_type'] as String)}';

      /// There are scenarios when the collections are not synced
      /// fully, we may end up creating one. However, other details for
      /// the newly created collection is not available at this stage, and
      /// we may need to fetch from server if needed. [KNOWN_ISSUE]
      if (map.containsKey('collectionLabel')) {
        map['collectionId'] =
            (await onGetCollectionByLabel(map['collectionLabel'] as String)).id;
      }

      /// Eventhough we can't find by serverUID, there is a possibiltity
      /// that the media with the same md5 exists. In this scenario,
      /// we simply need to adapt and update with serverUID instead
      /// as duplication is not possible.
      final mediaInDB = await onGetMedia(
        serverUID: map['serverUID'] as int,
        md5String: map['md5String'] as String,
      );

      final updatedMedia = StoreExtCLMedia.mediaFromServerMap(mediaInDB, map);
      if (updatedMedia != mediaInDB) {
        /* if (mediaInDB != null) {
          final diff = MapDiff.log(mediaInDB.toMap(), updatedMedia.toMap());
          
        } */
        updatesFromServer.add(updatedMedia);
      }
      allFromServer.add(updatedMedia);
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    return CLMedias(updatesFromServer);
  }
}