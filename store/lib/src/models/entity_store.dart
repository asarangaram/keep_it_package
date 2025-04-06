import 'package:meta/meta.dart';

import 'cl_entity.dart';
import 'store.dart';

@immutable
abstract class EntityStore {
  Future<CLEntity?> get([StoreQuery<CLEntity>? query]);
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]);
  Future<CLEntity?> upsert(
    CLEntity curr, {
    CLEntity? prev,
    String? mediaFile,
  });

  Future<bool> delete(CLEntity item);
}
