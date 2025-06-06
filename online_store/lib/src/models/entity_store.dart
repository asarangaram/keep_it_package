import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:online_store/src/implementations/cl_server.dart';

import 'package:store/store.dart';

import 'server_query.dart';

@immutable
class OnlineEntityStore extends EntityStore {
  OnlineEntityStore(super.identity, {required this.server});
  final CLServer server;
  final String path = '/entity';
  final validQueryKeys = const <String>{
    "id",
    "isCollection",
    "label",
    "parentId",
    "addedDate",
    "updatedDate",
    "isDeleted",
    "CreateDate",
    "FileSize",
    "ImageHeight",
    "ImageWidth",
    "Duration",
    "MIMEType",
    "md5",
    "type",
    "extension",
  };

  @override
  bool get isAlive => server.hasID;

  @override
  Future<CLEntity?> get([StoreQuery<CLEntity>? query]) async {
    final serverQuery = ServerQuery.fromStoreQuery(path, validQueryKeys, query);
    final map = jsonDecode(await server.getEndpoint(serverQuery.requestTarget))
        as List<dynamic>;
    final mediaMapList =
        map.map((e) => CLEntity.fromMap(e as Map<String, dynamic>)).firstOrNull;

    return mediaMapList;
  }

  @override
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]) async {
    if (query != null) {
      if (query.map.keys.contains('isHidden') && query.map['isHidden'] == 1) {
        // Servers don't support isHidden
        return [];
      }
    }
    final serverQuery = ServerQuery.fromStoreQuery(path, validQueryKeys, query);
    final map = jsonDecode(await server.getEndpoint(serverQuery.requestTarget));
    try {
      final items = ((map as Map<String, dynamic>)["items"]) as List<dynamic>;

      final mediaMapList = items
          .map((e) => CLEntity.fromMap(e as Map<String, dynamic>))
          .toList();
      return mediaMapList;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> delete(CLEntity item) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Uri? mediaUri(CLEntity media) {
    return Uri.parse("${server.baseURL}/entity/${media.id}/download");
  }

  @override
  Uri? previewUri(CLEntity media) {
    return Uri.parse("${server.baseURL}/entity/${media.id}/preview");
  }

  @override
  Future<CLEntity?> upsert(CLEntity curr, {String? path}) {
    // TODO: implement upsert
    throw UnimplementedError();
  }

  static Future<EntityStore> createStore(StoreURL url) async {
    final server = await CLServer(storeURL: url).getServerLiveStatus();

    return OnlineEntityStore(url.toString(), server: server);
  }
}

Future<EntityStore> createOnlineEntityStore(
  StoreURL url, {
  required String storePath,
}) async {
  return OnlineEntityStore.createStore(url);
}
