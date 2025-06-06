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
  final validQueryKeys = const <String>{};

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
    final serverQuery = ServerQuery.fromStoreQuery(path, validQueryKeys, query);
    final map = jsonDecode(await server.getEndpoint(serverQuery.requestTarget))
        as List<dynamic>;
    final mediaMapList =
        map.map((e) => CLEntity.fromMap(e as Map<String, dynamic>)).toList();

    return mediaMapList;
  }

  @override
  Future<bool> delete(CLEntity item) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Uri? mediaUri(CLEntity media) {
    // TODO: implement mediaUri
    throw UnimplementedError();
  }

  @override
  Uri? previewUri(CLEntity media) {
    // TODO: implement previewUri
    throw UnimplementedError();
  }

  @override
  Future<CLEntity?> upsert(CLEntity curr, {String? path}) {
    // TODO: implement upsert
    throw UnimplementedError();
  }

  static Future<EntityStore> createStore(
    String name, {
    required String mediaPath,
    required String previewPath,
  }) async {
    throw UnimplementedError();
  }
}

Future<EntityStore> createOnlineEntityStore(
  StoreURL url, {
  required String storePath,
}) async {
  throw UnimplementedError();
}
