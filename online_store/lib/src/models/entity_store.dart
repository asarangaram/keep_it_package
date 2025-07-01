import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';
import 'package:online_store/src/implementations/cl_server.dart';

import 'package:store/store.dart';

import 'server_query.dart';

@immutable
class OnlineEntityStore extends EntityStore {
  OnlineEntityStore(
      {required super.identity,
      required super.storeURL,
      required this.server}) {
    path = '/entity';
    validQueryKeys = const <String>{
      'id',
      'isCollection',
      'label',
      'parentId',
      'addedDate',
      'updatedDate',
      'isDeleted',
      'CreateDate',
      'FileSize',
      'ImageHeight',
      'ImageWidth',
      'Duration',
      'MIMEType',
      'md5',
      'type',
      'extension',
    };
  }

  final CLServer server;

  late final String path;
  late final Set<String> validQueryKeys;

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
      final items = ((map as Map<String, dynamic>)['items']) as List<dynamic>;

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
    // TODO(anandas): implement delete
    throw UnimplementedError();
  }

  @override
  Uri? mediaUri(CLEntity media) {
    return Uri.parse('${server.baseURL}/entity/${media.id}/download');
  }

  @override
  Uri? previewUri(CLEntity media) {
    return Uri.parse('${server.baseURL}/entity/${media.id}/preview');
  }

  @override
  Future<CLEntity?> upsert(CLEntity curr, {String? path}) {
    // TODO(anandas): implement upsert
    throw UnimplementedError();
  }

  static Future<EntityStore> createStore(
      {required StoreURL storeURL, required CLServer server}) async {
    return OnlineEntityStore(
        identity: server.baseURL, storeURL: storeURL, server: server);
  }
}

Future<EntityStore> createOnlineEntityStore({
  required StoreURL storeURL,
  required CLServer server,
  required String storePath,
}) async {
  return OnlineEntityStore.createStore(server: server, storeURL: storeURL);
}
