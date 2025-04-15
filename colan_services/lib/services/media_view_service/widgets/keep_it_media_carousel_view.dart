import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/basic_page_service/widgets/page_manager.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../../gallery_view_service/providers/active_collection.dart';
import '../media_view_service1.dart';
import 'get_sorted_entities.dart';

class KeepItMediaCorouselView extends ConsumerWidget {
  const KeepItMediaCorouselView({
    required this.parentIdentifier,
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    this.initialMediaIndex = 0,
    super.key,
  });
  final String parentIdentifier;
  final List<StoreEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;

  final int initialMediaIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = ref.watch(activeCollectionProvider);
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: parentId.toString(),
    );

    if (entities.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PageManager.of(context).pop();
      });
    }
    return GetSortedEntity(
      entities: entities,
      builder: (sorted) {
        return GetFilterredMedia(
          viewIdentifier: viewIdentifier,
          incoming: sorted,
          bannersBuilder: (context, _) => [],
          builder: (
            List<ViewerEntityMixin> filterred, {
            required List<Widget> Function(
              BuildContext,
              List<ViewerEntityGroup<ViewerEntityMixin>>,
            ) bannersBuilder,
          }) {
            return MediaViewService1.pageView(
              media: filterred.map((e) => e as StoreEntity).toList(),
              parentIdentifier: viewIdentifier.toString(),
              initialMediaIndex:
                  filterred.indexWhere((e) => e.id == initialMediaIndex),
              errorBuilder: errorBuilder,
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'MediaViewService.pageView',
              ),
            );
          },
        );
      },
    );
  }
}
