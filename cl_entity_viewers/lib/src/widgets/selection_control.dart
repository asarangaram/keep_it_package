import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_context_menu.dart';
import '../models/viewer_entity_mixin.dart';
import '../models/tab_identifier.dart';

import 'cl_raw_gallery_grid_view.dart';
import '../providers/media_filters.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';
import 'filter_banner.dart';
import 'selectable_item.dart';
import 'selectable_label.dart';
import 'selection_banner.dart';

class SelectionContol extends ConsumerWidget {
  const SelectionContol(
      {required this.viewIdentifier,
      required this.itemBuilder,
      required this.contextMenuBuilder,
      required this.onSelectionChanged,
      super.key,
      required this.filtersDisabled,
      required this.whenEmpty});
  final ViewIdentifier viewIdentifier;
  final bool filtersDisabled;
  final Widget whenEmpty;

  final Widget Function(
    BuildContext,
    ViewerEntityMixin,
  ) itemBuilder;

  final CLContextMenu Function(BuildContext, List<ViewerEntityMixin>)?
      contextMenuBuilder;
  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selector = ref.watch(selectorProvider);
    ref.listen(selectorProvider, (prev, curr) {
      onSelectionChanged?.call(curr.items.toList());
    });
    final incoming = selector.entities;
    final List<ViewerEntityMixin> filterred;
    if (filtersDisabled) {
      filterred = incoming;
    } else {
      filterred =
          ref.watch(filterredMediaProvider(MapEntry(viewIdentifier, incoming)));
    }

    /* return MediaViewService1.pageView(
          media: filterred.map((e) => e as StoreEntity).toList(),
          parentIdentifier: viewIdentifier.toString(),
          initialMediaIndex:
              filterred.indexWhere((e) => e.id == initialMediaIndex),
          errorBuilder: errorBuilder,
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'MediaViewService.pageView',
          ),
        ); */

    return CLRawGalleryGridView(
      viewIdentifier: viewIdentifier,
      incoming: filterred,
      bannersBuilder: (context, galleryMap) {
        return [
          FilterBanner(filterred: filterred, incoming: incoming),
          if (incoming.isNotEmpty)
            SelectionBanner(
              viewIdentifier: viewIdentifier,
              incoming: incoming,
              galleryMap: galleryMap,
            ),
        ];
      },
      labelBuilder: (context, galleryMap, gallery) => SelectableLabel(
        viewIdentifier: viewIdentifier,
        gallery: gallery,
        galleryMap: galleryMap,
      ),
      itemBuilder: (context, item) => SelectableItem(
        viewIdentifier: viewIdentifier,
        item: item,
        itemBuilder: itemBuilder,
      ),
      columns: 3,
      draggableMenuBuilder: selector.items.isNotEmpty &&
              contextMenuBuilder != null
          ? contextMenuBuilder!(context, selector.items.toList())
              .draggableMenuBuilder(context,
                  ref.read(selectModeProvider(viewIdentifier).notifier).disable)
          : null,
      whenEmpty: whenEmpty,
    );
  }
}
