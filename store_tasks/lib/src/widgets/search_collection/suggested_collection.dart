import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class SuggestedCollection extends StatelessWidget {
  const SuggestedCollection(
      {required this.item, required this.onSelect, super.key});

  final ViewerEntity item;
  final void Function(ViewerEntity) onSelect;

  @override
  Widget build(BuildContext context) {
    final targetStore = (item as StoreEntity).store;
    return Center(
      child: GestureDetector(
        onTap: () => onSelect(item),
        child: GetEntities(
            store: targetStore,
            parentId: item.id,
            errorBuilder: (_, __) => CLEntityView(
                  entity: item,
                ),
            loadingBuilder: () => CLEntityView(
                  entity: item,
                ),
            builder: (children) {
              return CLEntityView(entity: item, children: children);
            }),
      ),
    );
  }
}
