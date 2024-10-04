import 'dart:developer';

import 'package:content_store/db_service/models/store_updter_ext_store.dart';
import 'package:mime/mime.dart';
import 'package:store/store.dart';

import '../../db_service/models/store_updater.dart';
import '../../extensions/ext_cl_media.dart';
import '../../extensions/ext_store.dart';
import '../../extensions/list_ext.dart';

extension ServerExt on StoreUpdater {
  Future<void> sync(List<Map<String, dynamic>> mapList) async {
    final serverUpdates = await analyseChanges(
      mapList,
      createCollectionIfMissing: (label) async {
        return await store.reader.getCollectionByLabel(label) ??
            upsertCollection(Collection(label: label));
      },
    );
    print(serverUpdates);
    await Future<void>.delayed(const Duration(seconds: 10));
  }

  Future<MediaUpdatesFromServer> analyseChanges(
    List<dynamic> mediaMap, {
    required Future<Collection> Function(String label)
        createCollectionIfMissing,
  }) async {
    final mediaOnServerIter = mediaMap.map((e) => e as Map<String, dynamic>);
    final serverUIDOnServer =
        mediaOnServerIter.map((e) => e['serverUID'] as int);

    /// Any serverUID, found in local, but not in Server are 'deletedOnServer'
    final serverMediaAll =
        store.reader.getQuery<CLMedia>(DBQueries.serverUIDAll);

    /// Any item that don't have serverUID are local, ignore locally deleted
    final deletedOnServer =
        (await store.reader.readMultipleByQuery(serverMediaAll))
            .where((e) => !serverUIDOnServer.contains(e.serverUID))
            .toList();

    final deletedOnLocal = <CLMedia>[];
    final updatedOnServer = <CLMedia>[];
    final updatedOnLocal = <TrackedMedia>[];
    final newOnServer = <CLMedia>[];
    final allUpdates = <CLMedia>[];
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
            (await createCollectionIfMissing(map['collectionLabel'] as String))
                .id;
      }

      /// Eventhough we can't find by serverUID, there is a possibiltity
      /// that the media with the same md5 exists. In this scenario,
      /// we simply need to adapt and update with serverUID instead
      /// as duplication is not possible.
      final mediaInDB = await store.reader.getMedia(
        serverUID: map['serverUID'] as int,
        md5String: map['md5String'] as String,
      );
      final updated = StoreExtCLMedia.mediaFromServerMap(mediaInDB, map);
      final bool localChangeIsLatest;
      if (mediaInDB != null) {
        localChangeIsLatest = [updated.updatedDate, mediaInDB.updatedDate]
                .every((e) => e != null) &&
            updated.updatedDate!.isBefore(mediaInDB.updatedDate!);
      } else {
        localChangeIsLatest = false;
      }
      allUpdates.add(updated);
      if (mediaInDB == null) {
        newOnServer.add(updated);
      } else if (localChangeIsLatest && (mediaInDB.isDeleted ?? false)) {
        deletedOnLocal.add(mediaInDB);
      } else if (localChangeIsLatest && (mediaInDB.isEdited)) {
        updatedOnLocal.add(
          TrackedMedia(
            mediaInDB,
            StoreExtCLMedia.mediaFromServerMap(mediaInDB, map),
          ),
        );
      } else {
        updatedOnServer.add(
          StoreExtCLMedia.mediaFromServerMap(mediaInDB, map),
        );
      }

      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    final localMediaAll =
        store.reader.getQuery<CLMedia>(DBQueries.localMediaAll);
    final ids2Update = allUpdates.map((e) => e.id).nonNullableList;
    final newOnLocal = (await store.reader.readMultipleByQuery(localMediaAll))
        .where((e) => !ids2Update.contains(e.id));
    allUpdates.addAll(newOnLocal);
    final mediaUpdates = MediaUpdatesFromServer(
      deletedOnServer: List<CLMedia>.unmodifiable(deletedOnServer),
      deletedOnLocal: List<CLMedia>.unmodifiable(deletedOnLocal),
      updatedOnServer: List<CLMedia>.unmodifiable(updatedOnServer),
      updatedOnLocal: List.unmodifiable(updatedOnLocal),
      newOnServer: List<CLMedia>.unmodifiable(newOnServer),
      newOnLocal: List<CLMedia>.unmodifiable(newOnLocal),
    );

    log('Analyse Result: $mediaUpdates');

    return mediaUpdates;
  }
}
