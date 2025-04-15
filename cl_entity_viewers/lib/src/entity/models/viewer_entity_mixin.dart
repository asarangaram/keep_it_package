/* import 'package:store/src/extensions/ext_datetime.dart';
import 'package:store/src/extensions/ext_list.dart';

import 'gallery_group.dart'; */

import 'package:cl_media_tools/cl_media_tools.dart';

abstract class ViewerEntityMixin {
  int? get id;
  bool get isCollection;
  DateTime? get createDate;
  DateTime get updatedDate;
  int? get parentId;
  Uri? get mediaUri;
  Uri? get previewUri;
  String get searchableTexts;
  CLMediaType get mediaType;
}

class ViewerEntityGroup<T extends ViewerEntityMixin> {
  const ViewerEntityGroup(
    this.items, {
    required this.chunkIdentifier,
    required this.groupIdentifier,
    required this.label,
  });
  final String chunkIdentifier;
  final String groupIdentifier;
  final String? label;
  final List<T> items;

  Set<int?> get getEntityIds => items.map((e) => e.id).toSet();
}

extension GalleryGroupStoreEntityListQuery<T extends ViewerEntityMixin>
    on List<ViewerEntityGroup<T>> {
  Set<int?> get getEntityIds => expand((item) => item.getEntityIds).toSet();
  Set<T> get getEntities => expand((item) => item.items).toSet();

  Set<int?> getEntityIdsByGroup(String groupIdentifier) =>
      where((e) => e.groupIdentifier == groupIdentifier)
          .expand((item) => item.getEntityIds)
          .toSet();

  Set<T> getEntitiesByGroup(String groupIdentifier) =>
      where((e) => e.groupIdentifier == groupIdentifier)
          .expand((item) => item.items)
          .toSet();
}
