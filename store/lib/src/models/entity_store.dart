import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

import 'store_query.dart';
import 'store_url.dart';

@immutable
abstract class EntityStore {
  const EntityStore({required this.identity, required this.storeURL});
  final String identity;
  final StoreURL storeURL;

  bool get isAlive;
  Future<CLEntity?> get([StoreQuery<CLEntity>? query]);
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]);
  Future<CLEntity?> upsert(
    CLEntity curr, {
    String? path,
  });
  bool get isLocal => storeURL.scheme == 'local';

  Future<bool> delete(CLEntity item);

  Uri? mediaUri(CLEntity media);
  Uri? previewUri(CLEntity media);
}
