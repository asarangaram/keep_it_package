import 'package:meta/meta.dart';

import 'cl_entity.dart';

import 'store.dart';

@immutable
abstract class EntityStore {
  const EntityStore(this.identity);
  final String identity;
  Future<CLEntity?> get([StoreQuery<CLEntity>? query]);
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]);
  Future<CLEntity?> upsert(
    CLEntity curr, {
    CLEntity? prev,
    String? mediaFile,
  });

  Future<bool> delete(CLEntity item);
}
