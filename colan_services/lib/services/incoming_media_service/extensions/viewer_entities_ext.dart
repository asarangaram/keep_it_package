import 'package:cl_entity_viewers/cl_entity_viewers.dart'
    show ViewerEntities, ViewerEntity;
import 'package:store/store.dart';

extension DuplicateMergeOnViewerEntities on ViewerEntities {
  Future<ViewerEntities> mergeMismatch(int? parentId) async {
    final items = <StoreEntity>[];
    for (final e in entities.cast<StoreEntity>()) {
      final item = await e.updateWith(
        isDeleted: () => false,
        parentId: () => parentId,
      );
      if (item != null) {
        items.add(item);
      }
    }
    return ViewerEntities(items.toList());
  }

  ViewerEntities? removeMismatch(int? parentId) {
    final items = entities.cast<StoreEntity>().where(
          (e) => e.parentId == parentId || (e.data.isHidden),
        );
    if (items.isEmpty) return null;

    return ViewerEntities(items.toList());
  }

  ViewerEntities? remove(StoreEntity itemToRemove) {
    final items = entities.cast<StoreEntity>().where((e) => e != itemToRemove);
    if (items.isEmpty) return null;

    return ViewerEntities(items.toList());
  }

  Iterable<ViewerEntity> get _stored =>
      entities.where((e) => e.id != null).cast<StoreEntity>();
  Iterable<ViewerEntity> _targetMismatch(int? parentId) => _stored.where(
      (e) => e.parentId != parentId && !(e as StoreEntity).data.isHidden);

  ViewerEntities targetMismatch(int? parentId) =>
      ViewerEntities(_targetMismatch(parentId).toList());
  ViewerEntities get stored => ViewerEntities(_stored.toList());
}
