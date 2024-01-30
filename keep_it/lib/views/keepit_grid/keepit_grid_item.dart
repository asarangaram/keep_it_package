import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../widgets/wrap_standard_quick_menu.dart';

class KeepItGridItem extends ConsumerWidget {
  const KeepItGridItem({
    required this.quickMenuScopeKey,
    required this.entities,
    required this.previewGenerator,
    required this.itemSize,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.lastupdatedID, // Must avoid to item !
    super.key,
  });
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final List<CollectionBase> entities;
  final Future<bool?> Function(
    BuildContext context,
    CollectionBase entity,
  )? onEdit;
  final Future<bool?> Function(
    BuildContext context,
    CollectionBase entity,
  )? onDelete;
  final Future<bool?> Function(
    BuildContext context,
    CollectionBase entity,
  )? onTap;
  final int? lastupdatedID;
  final Widget Function(BuildContext context, CollectionBase entity)
      previewGenerator;
  final Size itemSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highLightIndex = lastupdatedID == null
        ? -1
        : entities.indexWhere((e) => e.id == lastupdatedID);

    return CLMatrix3DAutoFit(
      childSize: itemSize,
      itemCount: entities.length,
      layers: 2,
      visibleItem: highLightIndex <= -1 ? null : highLightIndex,
      itemBuilder: (context, index, layer) {
        final entity = entities[index];
        if (layer == 0) {
          return CLHighlighted(
            isHighlighed: index == highLightIndex,
            child: WrapStandardQuickMenu(
              quickMenuScopeKey: quickMenuScopeKey,
              onEdit: () async => onEdit!.call(
                context,
                entity,
              ),
              onDelete: () async => onDelete!.call(
                context,
                entity,
              ),
              onTap: () async => onTap!.call(
                context,
                entity,
              ),
              child: previewGenerator(context, entity),
            ),
          );
        } else if (layer == 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              entities[index].label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
        throw Exception('Incorrect layer');
      },
    );
  }
}
