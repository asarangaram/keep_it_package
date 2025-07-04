import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';
import 'package:online_store/src/implementations/api_response.dart';
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
    try {
      final serverQuery =
          ServerQuery.fromStoreQuery(path, validQueryKeys, query);
      final reply = await server.getEndpoint(serverQuery.requestTarget);
      return reply.when(
          validResponse: (data) {
            final map = jsonDecode(data);
            final items =
                ((map as Map<String, dynamic>)['items']) as List<dynamic>;

            final mediaMapList = items
                .map((e) => CLEntity.fromMap(e as Map<String, dynamic>))
                .toList();
            return mediaMapList.firstOrNull;
          },
          errorResponse: (e) => null);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]) async {
    late StoreReply<List<CLEntity>> serverReply;
    try {
      if (query != null &&
          query.map.keys.contains('isHidden') &&
          query.map['isHidden'] == 1) {
        // Servers don't support isHidden
        serverReply = StoreResult(const []);
      } else {
        final serverQuery =
            ServerQuery.fromStoreQuery(path, validQueryKeys, query);
        final reply = await server.getEndpoint(serverQuery.requestTarget);
        switch (reply) {
          case (final StoreResult<String> response):
            final map = jsonDecode(response.result);
            final items =
                ((map as Map<String, dynamic>)['items']) as List<dynamic>;

            final mediaMapList = items
                .map((e) => CLEntity.fromMap(e as Map<String, dynamic>))
                .toList();
            serverReply = StoreResult(mediaMapList);
          case (final StoreError<String> e):
            serverReply = StoreError(e.error, st: e.st, errorCode: e.errorCode);
          default:
            serverReply = StoreError<List<CLEntity>>('Unknown Error');
        }
      }
    } catch (e, st) {
      serverReply = StoreError<List<CLEntity>>(e.toString(), st: st);
    }
    switch (serverReply) {
      case (final StoreResult<List<CLEntity>> response):
        return response.result;
      case (final StoreError<List<CLEntity>> e):
        throw Exception(e);
      default:
        throw Exception('Unknown Error');
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
  Future<CLEntity?> upsert(CLEntity curr, {String? path}) async {
    try {
      final StoreReply<String> reply;
      if (curr.id == null) {
        final form = {
          'isCollection': curr.isCollection ? '1' : '0',
          if (curr.label != null) 'label': curr.label,
          if (curr.description != null) 'description': curr.description,
          if (curr.parentId != null) 'parentId': curr.parentId
        };

        reply = await server.post('/entity', fileName: path, form: form);
      } else {
        final form = {
          'isCollection': curr.isCollection ? '1' : '0',
          if (curr.label != null) 'label': curr.label,
          if (curr.description != null) 'description': curr.description,
          if (curr.parentId != null) 'parentId': curr.parentId
        };

        reply = await server.put('/${curr.id}', fileName: path, form: form);
      }
      return reply.when(
          validResponse: CLEntity.fromJson,
          errorResponse: (e) => throw Exception(e));
    } catch (e) {
      return null;
    }
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
