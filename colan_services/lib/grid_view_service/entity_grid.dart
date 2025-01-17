import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

import 'widgets/cl_entity_grid_view.dart';
import 'widgets/grouper.dart';
import 'widgets/selection_control.dart';

class CLEntityGrid extends StatelessWidget {
  const CLEntityGrid({
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.itemBuilder,
    required this.parentIdentifier,
    required this.numColumns,
    required this.getGrouped,
    required this.selectionMode,
    required this.onChangeSelectionMode,
    required this.whenEmpty,
    super.key,
  });
  final List<CLEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function(
    BuildContext,
    CLEntity, {
    required String parentIdentifier,
  }) itemBuilder;
  final String parentIdentifier;
  final int numColumns;
  final Future<List<GalleryGroupCLEntity<CLEntity>>> Function(
    List<CLEntity> entities,
  ) getGrouped;
  final bool selectionMode;
  final void Function({required bool enable}) onChangeSelectionMode;
  final Widget whenEmpty;
  @override
  Widget build(BuildContext context) {
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
          ? whenEmpty
          : SelectionControl(
              selectionMode: selectionMode,
              onChangeSelectionMode: onChangeSelectionMode,
              incoming: entities,
              itemBuilder: (context, item) => itemBuilder(
                context,
                item,
                parentIdentifier: parentIdentifier,
              ),
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
              }) {
                return GetFilterredMedia(
                  errorBuilder: errorBuilder,
                  loadingBuilder: loadingBuilder,
                  incoming: entities,
                  bannersBuilder: bannersBuilder,
                  builder: (
                    List<CLEntity> filterred, {
                    required List<Widget> Function(
                      BuildContext,
                      List<GalleryGroupCLEntity<CLEntity>>,
                    ) bannersBuilder,
                  }) {
                    return GetGroupedMedia(
                      errorBuilder: errorBuilder,
                      loadingBuilder: loadingBuilder,
                      incoming: filterred,
                      columns: numColumns,
                      getGrouped: getGrouped,
                      builder: (galleryMap /* numColumns */) {
                        return CLEntityGridView(
                          identifier: parentIdentifier,
                          galleryMap: galleryMap,
                          bannersBuilder: bannersBuilder,
                          labelBuilder: labelBuilder,
                          itemBuilder: itemBuilder,
                          columns: numColumns,
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
