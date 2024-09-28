// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:content_store/db_service/extensions/ext_cl_media.dart';
import 'package:content_store/db_service/extensions/list_ext.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:store/store.dart';

@immutable
class TrackedMedia {
  const TrackedMedia(this.current, this.update);
  final CLMedia current;
  final CLMedia update;

  @override
  bool operator ==(covariant TrackedMedia other) {
    if (identical(this, other)) return true;

    return other.current == current && other.update == update;
  }

  @override
  int get hashCode => current.hashCode ^ update.hashCode;

  @override
  String toString() => 'TrackedMedia(current: $current, update: $update)';
}

@immutable
class MediaUpdatesFromServer {
  const MediaUpdatesFromServer({
    required this.deletedOnServer,
    required this.deletedOnLocal,
    required this.updatedOnServer,
    required this.updatedOnLocal,
    required this.newOnServer,
    required this.newOnLocal,
  });
  final List<CLMedia> deletedOnServer;
  final List<CLMedia> deletedOnLocal;
  final List<CLMedia> updatedOnServer;
  final List<TrackedMedia> updatedOnLocal;
  final List<CLMedia> newOnServer;
  final List<CLMedia> newOnLocal;

  @override
  bool operator ==(covariant MediaUpdatesFromServer other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.deletedOnServer, deletedOnServer) &&
        listEquals(other.deletedOnLocal, deletedOnLocal) &&
        listEquals(other.updatedOnServer, updatedOnServer) &&
        listEquals(other.updatedOnLocal, updatedOnLocal) &&
        listEquals(other.newOnServer, newOnServer) &&
        listEquals(other.newOnLocal, newOnLocal);
  }

  @override
  int get hashCode {
    return deletedOnServer.hashCode ^
        deletedOnLocal.hashCode ^
        updatedOnServer.hashCode ^
        updatedOnLocal.hashCode ^
        newOnServer.hashCode ^
        newOnLocal.hashCode;
  }

  @override
  String toString() {
    return 'MediaUpdatesFromServer( '
        'deletedOnServer: ${deletedOnServer.length}, '
        'deletedOnLocal: ${deletedOnLocal.length}, '
        'updatedOnServer: ${updatedOnServer.length}, '
        'updatedOnLocal: ${updatedOnLocal.length}, '
        'newOnServer: ${newOnServer.length}, '
        'newOnLocal: ${newOnLocal.length})';
  }
}

extension StoreReaderExt on StoreReader {
  Future<List<CLMedia>> notesByMediaId(int mediaId) async {
    final q = getQuery(DBQueries.notesByMediaId, parameters: [mediaId])
        as StoreQuery<CLMedia>;
    return (await readMultiple(q)).nonNullableList;
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
    final serverMediaAll = getQuery<CLMedia>(DBQueries.serverUIDAll);

    /// Any item that don't have serverUID are local, ignore locally deleted
    final deletedOnServer = (await readMultipleByQuery(serverMediaAll))
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
      final mediaInDB = await getMedia(
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

    final localMediaAll = getQuery<CLMedia>(DBQueries.localMediaAll);
    final ids2Update = allUpdates.map((e) => e.id).nonNullableList;
    final newOnLocal = (await readMultipleByQuery(localMediaAll))
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

  Future<List<T>> readMultipleByQuery<T>(StoreQuery<T> q) async {
    return (await readMultiple<T>(q)).nonNullableList;
  }
}
