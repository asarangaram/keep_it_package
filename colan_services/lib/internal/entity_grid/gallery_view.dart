import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart' show CLEntity, GalleryGroupCLEntity;

import 'widgets/gallery_view.dart';
import 'widgets/selection_control/selection_control.dart';

class CLEntityGalleryView extends ConsumerWidget {
  const CLEntityGalleryView({
    required this.viewIdentifier,
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.itemBuilder,
    required this.numColumns,
    required this.emptyWidget,
    required this.selectionActionsBuilder,
    super.key,
    this.filterDisabled = false,
    this.onSelectionChanged,
  });
  final ViewIdentifier viewIdentifier;
  final List<CLEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function(
    BuildContext,
    CLEntity,
  ) itemBuilder;
  final int numColumns;

  final Widget emptyWidget;
  final List<CLMenuItem> Function(BuildContext, List<CLEntity>)?
      selectionActionsBuilder;
  final void Function(List<CLEntity>)? onSelectionChanged;
  final bool filterDisabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
      ) =>
          FadeTransition(opacity: animation, child: child),
      child: entities.isEmpty
          ? emptyWidget
          : SelectionControl(
              viewIdentifier: viewIdentifier,
              draggableMenuItemsBuilder: selectionActionsBuilder,
              onSelectionChanged: onSelectionChanged,
              incoming: entities,
              itemBuilder: itemBuilder,
              labelBuilder: (context, galleryMap, gallery) {
                return gallery.label == null
                    ? null
                    : CLText.large(
                        gallery.label!,
                        textAlign: TextAlign.start,
                      );
              },
              bannersBuilder: (context, galleryMap) {
                return [];
              },
              builder: ({
                required items,
                required itemBuilder,
                required labelBuilder,
                required bannersBuilder,
                draggableMenuBuilder,
              }) {
                return GetFilterredMedia(
                  viewIdentifier: viewIdentifier,
                  errorBuilder: errorBuilder,
                  loadingBuilder: loadingBuilder,
                  incoming: entities,
                  bannersBuilder: bannersBuilder,
                  disabled: filterDisabled,
                  builder: (
                    List<CLEntity> filterred, {
                    required List<Widget> Function(
                      BuildContext,
                      List<GalleryGroupCLEntity<CLEntity>>,
                    ) bannersBuilder,
                  }) {
                    return GetGroupedMedia(
                      viewIdentifier: viewIdentifier,
                      errorBuilder: errorBuilder,
                      loadingBuilder: loadingBuilder,
                      incoming: filterred,
                      columns: numColumns,
                      builder: (tabs /* numColumns */) {
                        return RawCLEntityGalleryView(
                          viewIdentifier: viewIdentifier,
                          tabs: tabs,
                          bannersBuilder: bannersBuilder,
                          labelBuilder: labelBuilder,
                          itemBuilder: itemBuilder,
                          numColumns: numColumns,
                          draggableMenuBuilder: draggableMenuBuilder,
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
