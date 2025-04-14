import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:meta/meta.dart';
import 'package:store/src/models/cl_store.dart';

import 'cl_entity.dart';
import 'data_types.dart';
import 'viewer_entity_mixin.dart';

@immutable
class StoreEntity implements ViewerEntityMixin {
  factory StoreEntity({
    required CLEntity entity,
    required CLStore store,
    String? path,
  }) {
    return StoreEntity._(
      data: entity,
      store: store,
      path: path,
    );
  }
  const StoreEntity._({
    required this.data,
    required this.store,
    this.path,
  });

  final CLEntity data;
  final CLStore store;
  final String? path;

  Future<StoreEntity?> updateWith({
    CLMediaFile? mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String?>? pin,
    UpdateStrategy? strategy,
    bool autoSave = false,
  }) async {
    StoreEntity? updated;
    if (data.isCollection) {
      updated = await store.updateCollection(
        data,
        label: label,
        description: description,
        parentId: parentId,
        isDeleted: isDeleted,
        isHidden: isHidden,
        strategy: strategy ?? UpdateStrategy.mergeAppend,
      );
    } else {
      updated = await store.updateMedia(
        data,
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
    if (updated != null && autoSave) {
      return dbSave(mediaFile?.path);
    }
    return updated;
  }

  Future<StoreEntity?> cloneWith({
    required CLMediaFile mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String?>? pin,
    UpdateStrategy? strategy,
    bool autoSave = false,
  }) async {
    final updated = await store.updateMedia(
      data,
      mediaFile: mediaFile,
      label: label,
      description: description,
      parentId: parentId,
      isDeleted: isDeleted,
      isHidden: isHidden,
      pin: pin,
      strategy: strategy ?? UpdateStrategy.mergeAppend,
    );
    if (updated == null) {
      return null;
    }

    return StoreEntity(
      entity: updated.data.clone(id: () => null),
      store: store,
    ).dbSave(mediaFile.path);
  }

  Future<StoreEntity?> dbSave([String? path]) {
    return store.dbSave(this, path: path);
  }

  Future<void> delete() async {
    if (data.id == null) {
      throw Exception("id can't be null");
    }
    await store.delete(data.id!);
  }

  Future<StoreEntity?> onPin() async {
    // Pin here, if not pinned
    return updateWith(pin: () => 'PIN TEST');
  }

  Future<StoreEntity?> onUnpin() async {
    // remove Pin here, if not pinned
    return updateWith(pin: () => null);
  }

  Future<StoreEntity?> getParent() async {
    final entity =
        await store.get(EntityQuery(store.store.identity, {'id': parentId}));
    return entity;
  }

  Future<List<StoreEntity>?> getChildren() async {
    if (!data.isCollection) return null;
    final entities = await store
        .getAll(EntityQuery(store.store.identity, {'parentId': parentId}));
    return entities;
  }

  @override
  int? get id => data.id;

  @override
  bool get isCollection => data.isCollection;

  @override
  DateTime get sortDate => data.createDate ?? data.updatedDate;

  @override
  int? get parentId => data.parentId;

  @override
  Uri? get mediaUri => store.store.mediaUri(data);
  @override
  Uri? get previewUri => store.store.previewUri(data);

  @override
  String toString() => 'StoreEntity(entity: $data, store: $store, path: $path)';

  @override
  bool operator ==(covariant StoreEntity other) {
    if (identical(this, other)) return true;

    return other.data == data && other.store == store && other.path == path;
  }

  @override
  int get hashCode => data.hashCode ^ store.hashCode ^ path.hashCode;
}
