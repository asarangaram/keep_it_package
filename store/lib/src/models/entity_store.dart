import 'package:meta/meta.dart';

import 'cl_entity.dart';

import 'store_query.dart';

@immutable
abstract class EntityStore {
  const EntityStore(this.identity);
  final String identity;

  bool get isAlive;
  Future<CLEntity?> get([StoreQuery<CLEntity>? query]);
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]);
  Future<CLEntity?> upsert(
    CLEntity curr, {
    String? path,
  });

  Future<bool> delete(CLEntity item);

  Uri? mediaUri(CLEntity media);
  Uri? previewUri(CLEntity media);
}
