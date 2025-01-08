import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/group_view.dart';

class MediaGalleryView extends ConsumerWidget {
  const MediaGalleryView({
    required this.title,
    required this.identifier,
    required this.medias,
    required this.emptyState,
    required this.itemBuilder,
    required this.columns,
    required this.backButton,
    required this.actions,
    super.key,
    this.onRefresh,
    this.selectionActions,
    this.topWidget,
    this.bottomWidget,
    this.popupActionItems = const [],
  });

  final String title;
  final CLMedias medias;
  final int columns;

  final Widget emptyState;
  final String identifier;
  final List<Widget> actions;
  final List<CLMenuItem> popupActionItems;

  final Future<void> Function()? onRefresh;
  final List<CLMenuItem> Function(
    BuildContext context,
    List<CLMedia> selectedItems,
  )? selectionActions;
  final ItemBuilder<CLMedia> itemBuilder;
  final Widget? backButton;

  final Widget? topWidget;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryMap = ref.watch(groupedItemsProvider(medias.entries));
    return CLSimpleGalleryView(
      title: title,
      identifier: identifier,
      galleryMap: galleryMap,
      emptyState: emptyState,
      itemBuilder: itemBuilder,
      columns: columns,
      backButton: backButton,
      actions: actions,
      onRefresh: onRefresh,
      selectionActions: selectionActions,
      topWidget: topWidget,
      bottomWidget: bottomWidget,
      popupActionItems: popupActionItems,
    );
  }
}
