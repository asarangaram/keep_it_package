// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:store/store.dart';
import 'cl_server.dart';
import 'rest_api.dart';

@immutable
class CLServerImpl extends CLServer {
  const CLServerImpl({
    required super.name,
    required super.port,
    super.id,
  });

  CLServerImpl copyWith({
    String? name,
    int? port,
    int? id,
  }) {
    return CLServerImpl(
      name: name ?? super.name,
      port: port ?? super.port,
      id: id ?? super.id,
    );
  }

  @override
  String toString() => 'CLServerImpl(name: $name, port: $port, id: $id)';

  @override
  bool operator ==(covariant CLServerImpl other) {
    if (identical(this, other)) return true;

    return other.name == name && other.port == port && other.id == id;
  }

  @override
  int get hashCode => name.hashCode ^ port.hashCode ^ id.hashCode;

  @override
  Future<CLServerImpl?> withId({http.Client? client}) async {
    try {
      final id =
          await RestApi('http://$name:$port', client: client).getURLStatus();
      if (id == null) {
        throw Exception('Missing id');
      }
      return copyWith(id: id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> hasConnection({http.Client? client}) async {
    try {
      final id =
          await RestApi('http://$name:$port', client: client).getURLStatus();
      return this.id != null && this.id == id;
    } catch (e) {
      return false;
    }
  }

  bool get hasID => id != null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'port': port,
      'id': id,
    };
  }

  factory CLServerImpl.fromMap(Map<String, dynamic> map) {
    return CLServerImpl(
      name: map['name'] as String,
      port: map['port'] as int,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CLServerImpl.fromJson(String source) =>
      CLServerImpl.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String get identifier {
    const separator = '_';
    if (id == null) return 'Unknown';

    var hexString = id!.toRadixString(16).toUpperCase();
    hexString = hexString.padLeft(4, '0');
    final formattedHex = hexString.replaceAllMapped(
      RegExp('.{4}'),
      (match) => '${match.group(0)}$separator',
    );
    final identifierString = formattedHex.endsWith(separator)
        ? formattedHex.substring(0, formattedHex.length - 1)
        : formattedHex;
    return identifierString;
  }

  @override
  Uri getEndpointURI(String endPoint) {
    return Uri.parse('http://$name:$port$endPoint');
  }

  @override
  Future<String> getEndpoint(
    String endPoint, {
    http.Client? client,
  }) async =>
      RestApi('http://$name:$port', client: client).get(endPoint);

  Future<Collections> downloadCollections({
    http.Client? client,
  }) async {
    if (!await hasConnection(client: client)) {
      throw Exception(DBSyncStatus.serverNotReachable.name);
    }
    final collectionJSON = await getEndpoint('/collection', client: client);
    final collections = Collections.fromJson(collectionJSON);
    return Collections(
      collections.entries
          .map(
            (e) => e.copyWith(),
          )
          .toList(),
    );
  }

  @override
  Future<String?> download(
    String endPoint,
    String targetFilePath, {
    http.Client? client,
  }) async {
    return RestApi('http://$name:$port', client: client)
        .download(endPoint, targetFilePath);
  }

  @override
  Future<List<CLMedia>> toStoreSync(
    Store store, {
    http.Client? client,
  }) async {
    if (!await hasConnection(client: client)) {
      return [];
    }

    final mediaMap = [
      for (final mediaType in ['image', 'video'])
        ...jsonDecode(
          await getEndpoint('/media?type=$mediaType', client: client),
        ) as List<dynamic>,
    ];
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
        final collectionLabel = map['collectionLabel'] as String;
        final collection = (await store
                .getCollectionByLabel(collectionLabel)) ??
            await store.upsertCollection(Collection(label: collectionLabel));
        map['collectionId'] = collection.id;
      }

      /// Eventhough we can't find by serverUID, there is a possibiltity
      /// that the media with the same md5 exists. In this scenario,
      /// we simply need to adapt and update with serverUID instead
      /// as duplication is not possible.
      final mediaInDB =
          await store.getMediaByServerUID(map['serverUID'] as int) ??
              await store.getMediaByMD5String(map['md5String'] as String);
      final updatedMedia = mediaFromServerMap(mediaInDB, map);
      if (updatedMedia != mediaInDB) {
        /* if (mediaInDB != null) {
          final diff = MapDiff.log(mediaInDB.toMap(), updatedMedia.toMap());
          
        } */
        updatesFromServer
            .add((await store.upsertMedia(updatedMedia)) ?? updatedMedia);
      }
      allFromServer.add(updatedMedia);
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    return updatesFromServer;
  }

  CLMedia mediaFromServerMap(
    CLMedia? mediaInDB,
    Map<String, dynamic> map,
  ) {
    /// if the media is pinned already,
    ///   we can't proceed here as the pin need to be updated.
    ///   we can't update pin on mobile devices without user action
    if (mediaInDB?.pin != null) {
      // Mark conflict
      return mediaInDB!;
    }

    /// If we have found by serverUID, and if it is Deleted
    /// the delete message is yet to upload, hence we can't update this media.
    if (mediaInDB?.serverUID != null && (mediaInDB!.isDeleted ?? false)) {
      return mediaInDB;
    }

    /// Check if the media in server is changed by comparing md5
    /// if media is changed / different
    ///   A. It was locally changed, and upload didn't happen correctly or
    ///       yet to be scheduled. In this case, mark it as conflict
    ///       abd return
    if (mediaInDB?.md5String != map['md5String'] &&
        (mediaInDB?.isEdited ?? false)) {
      // Mark conflict
      return mediaInDB!;
    }

    map['id'] = mediaInDB?.id;
    if (mediaInDB?.md5String == map['md5String']) {
      map['isPreviewCached'] = mediaInDB!.isPreviewCached ? 1 : 0;
      map['isMediaCached'] = mediaInDB.isMediaCached ? 1 : 0;
      map['isMediaOriginal'] = mediaInDB.isMediaOriginal ? 1 : 0;
    } else {
      map['isPreviewCached'] = 0;
      map['isMediaCached'] = 0;
      map['isMediaOriginal'] = 0;
    }

    map['previewLog'] = null;
    map['mediaLog'] = null;
    map['isDeleted'] = 0; // Deleted Media won't be received in normal download.
    map['isHidden'] = 0; // Media from server won't be hidden locally
    map['pin'] = null;
    map['isEdited'] = 0;
    map['haveItOffline'] = (mediaInDB?.haveItOffline ?? true) ? 1 : 0;
    map['mustDownloadOriginal'] =
        (mediaInDB?.mustDownloadOriginal ?? false) ? 1 : 0;
    return CLMedia.fromMap(map);
  }
}
