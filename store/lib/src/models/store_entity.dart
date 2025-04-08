import 'package:cl_media_info_extractor/cl_media_info_extractor.dart';
import 'package:meta/meta.dart';
import 'package:store/src/models/cl_store.dart';

import 'cl_entity.dart';
import 'data_types.dart';

@immutable
class StoreEntity {
  const StoreEntity({
    required this.entity,
    required this.store,
  });

  final CLEntity entity;
  final CLStore store;

  Future<StoreEntity?> updateWith({
    CLMediaFile? mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String>? pin,
    UpdateStrategy? strategy,
  }) async {
    if (entity.id == null) {
      throw Exception("id can't be null");
    }
    if (entity.isCollection) {
      return store.updateCollection(
        entity.id!,
        label: label,
        description: description,
        parentId: parentId,
        isDeleted: isDeleted,
        isHidden: isHidden,
        strategy: strategy ?? UpdateStrategy.mergeAppend,
      );
    } else {
      return store.updateMedia(
        entity.id!,
        mediaFile: mediaFile,
        label: label,
        description: description,
        parentId: parentId,
        isDeleted: isDeleted,
        isHidden: isHidden,
        pin: pin,
        strategy: strategy ?? UpdateStrategy.mergeAppend,
      );
    }
  }

  Future<void> delete() async {
    if (entity.id == null) {
      throw Exception("id can't be null");
    }
    await store.delete(entity.id!);
  }

  int get id => entity.id!;
}
