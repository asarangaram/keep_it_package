import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';
import 'package:online_store/src/implementations/cl_server.dart';
import 'package:online_store/src/implementations/store_reply.dart';
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
    if (query != null &&
        query.map.keys.contains('isHidden') &&
        query.map['isHidden'] == 1) {
      // Servers don't support isHidden
      return null;
    }
    final serverQuery = ServerQuery.fromStoreQuery(path, validQueryKeys, query);

    final reply = await server.getEntity(serverQuery.requestTarget);
    return reply.when(
      validResponse: (result) {
        return result == null ? null : CLEntity.fromMap(result);
      },
      errorResponse: (error, {st}) {
        return null;
      },
    );
  }

  @override
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]) async {
    if (query != null &&
        query.map.keys.contains('isHidden') &&
        query.map['isHidden'] == 1) {
      // Servers don't support isHidden
      return [];
    }
    final serverQuery = ServerQuery.fromStoreQuery(path, validQueryKeys, query);
    final reply = await server.getEntities(serverQuery.requestTarget);
    return reply.when(
        validResponse: (result) => result.map(CLEntity.fromMap).toList(),
        errorResponse: (e, {st}) => throw Exception(e));
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

  Future<StoreReply<CLEntity?>> upsert0(CLEntity curr, {String? path}) async {
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
          validResponse: (result) => StoreResult(CLEntity.fromJson(result)),
          errorResponse: (e, {st}) => StoreError(e, st: st));
    } catch (e, st) {
      return StoreError({'error': e.toString()}, st: st);
    }
  }

  @override
  Future<CLEntity?> upsert(CLEntity curr, {String? path}) async {
    final response = await upsert0(curr, path: path);

    return response.when(
        validResponse: (result) => result,
        errorResponse: (e, {st}) => throw Exception(e));
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
