import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../internal/gallery_view/cl_simple_gallery_view.dart';
import '../providers/group_view.dart';

class MediaGalleryView extends ConsumerWidget {
  const MediaGalleryView({
    required this.identifier,
    required this.medias,
    required this.emptyState,
    required this.itemBuilder,
    required this.columns,
    super.key,
    this.onRefresh,
    this.selectionActions,
  });

  final CLMedias medias;
  final int columns;

  final Widget emptyState;
  final String identifier;

  final Future<void> Function()? onRefresh;
  final List<CLMenuItem> Function(
    BuildContext context,
    List<CLMedia> selectedItems,
  )? selectionActions;
  final ItemBuilder<CLMedia> itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryMap = ref.watch(groupedItemsProvider(medias.entries));
    return CLSimpleGalleryView(
      identifier: identifier,
      galleryMap: galleryMap,
      emptyState: emptyState,
      itemBuilder: itemBuilder,
      columns: columns,
      actions: const [],
      selectionActions: selectionActions,
    );
  }
}
