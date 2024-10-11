// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:background_downloader/background_downloader.dart';
import 'package:content_store/db_service/models/store_updter_ext_store.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:store/store.dart';

import '../../db_service/models/store_updater.dart';
import '../../extensions/ext_cl_media.dart';
import '../../extensions/ext_store.dart';
import '../../extensions/list_ext.dart';
import 'downloader.dart';

@immutable
class TaskCompleter {
  const TaskCompleter(this.task, this.completer);
  final Task task;
  final Completer<void> completer;

  @override
  String toString() => 'TaskCompleter(task: $task, completer: $completer)';
}

extension ServerExt on StoreUpdater {
  Future<void> sync(
    List<Map<String, dynamic>> mapList, {
    required Future<TransferHandle> Function(
      CLMedia media,
      String group, {
      required Map<String, String> fields,
    }) onUploadMedia,
  }) async {
    final serverUpdates = await analyseChanges(
      mapList,
      createCollectionIfMissing: (label) async {
        return await store.reader.getCollectionByLabel(label) ??
            upsertCollection(Collection(label: label));
      },
    );

    await updateChanges(serverUpdates, onUploadMedia: onUploadMedia);
    // await Future<void>.delayed(const Duration(seconds: 10));
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
        localChangeIsLatest =
            updated.updatedDate.isBefore(mediaInDB.updatedDate);
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
        final updateMedia = StoreExtCLMedia.mediaFromServerMap(mediaInDB, map);

        updatedOnServer.add(
          updateMedia,
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

  Future<bool> updateChanges(
    MediaUpdatesFromServer updates, {
    required Future<TransferHandle> Function(
      CLMedia media,
      String group, {
      required Map<String, String> fields,
    }) onUploadMedia,
  }) async {
    var result = true;

    if (updates.deletedOnServer.isNotEmpty) {
      result = await permanentlyDeleteMediaMultipleById(
        updates.deletedOnServer.map((e) => e.id!).toSet(),
      );
    }
    final upserts = [...updates.updatedOnServer, ...updates.newOnServer];
    if (upserts.isNotEmpty) {
      try {
        for (final m in updates.updatedOnServer) {
          await upsertMedia(m, shouldRefresh: false);
        }
        for (final m in updates.newOnServer) {
          await upsertMedia(m, shouldRefresh: false);
        }
      } catch (e) {
        result |= false;
      }
    }
    if (updates.newOnLocal.isNotEmpty) {
      result |= await insertMediaOnServer(
        {...updates.newOnLocal},
        onUploadMedia: onUploadMedia,
      );
    }

    /* result |= await insertMediaOnServer({...updates.newOnLocal});
    result |= await updateMediaOnServer({...updates.updatedOnLocal});
    result |= await deleteMediaByIdOnServer(
      {...updates.deletedOnServer},
    ); */

    return result;
  }

  Future<bool> insertMediaOnServer(
    Set<CLMedia> mediaSet, {
    required Future<TransferHandle> Function(
      CLMedia media,
      String group, {
      required Map<String, String> fields,
    }) onUploadMedia,
  }) async {
    log('trigger upload for ${mediaSet.length} new media');
    final currentTasks = <TransferHandle>[];
    for (final media in mediaSet) {
      if (media.collectionId != null) {
        {
          final collection =
              await store.reader.getCollectionById(media.collectionId!);
          final fields = media.toUploadMap();
          fields['collectionLabel'] = collection!.label;

          final instance = await onUploadMedia(
            media,
            'upload',
            fields: fields,
          );

          currentTasks.add(instance);
        }
      }
    }
    // ignore: unused_local_variable
    final results =
        await Future.wait(currentTasks.map((e) => e.completer.future));

    // FIXME: Handle results here

    return false;
  }

  Future<bool> updateMediaOnServer(Set<TrackedMedia> mediaSet) async {
    return false;
  }

  Future<bool> deleteMediaByIdOnServer(Set<CLMedia> mediaSet) async {
    return false;
  }
}
