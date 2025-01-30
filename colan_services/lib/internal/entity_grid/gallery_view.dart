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
    required this.parentIdentifier,
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.itemBuilder,
    required this.numColumns,
    required this.selectionMode,
    required this.onChangeSelectionMode,
    required this.emptyWidget,
    required this.selectionActionsBuilder,
    required this.onClose,
    super.key,
    this.filterDisabled = false,
    this.onSelectionChanged,
  });
  final String parentIdentifier;
  final List<CLEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function(
    BuildContext,
    CLEntity,
  ) itemBuilder;
  final int numColumns;

  final bool selectionMode;
  final void Function({required bool enable}) onChangeSelectionMode;
  final Widget emptyWidget;
  final List<CLMenuItem> Function(BuildContext, List<CLEntity>)?
      selectionActionsBuilder;
  final void Function(List<CLEntity>)? onSelectionChanged;
  final bool filterDisabled;
  final VoidCallback? onClose;
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
              onClose: onClose,
              selectionMode: selectionMode,
              onChangeSelectionMode: onChangeSelectionMode,
              selectionActionsBuilder: selectionActionsBuilder,
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
              }) {
                return GetFilterredMedia(
                  parentIdentifier: parentIdentifier,
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
                      parentIdentifier: parentIdentifier,
                      errorBuilder: errorBuilder,
                      loadingBuilder: loadingBuilder,
                      incoming: filterred,
                      columns: numColumns,
                      builder: (galleryMap /* numColumns */) {
                        return RawCLEntityGalleryView(
                          viewIdentifier: parentIdentifier,
                          tabs: const [],
                          bannersBuilder: bannersBuilder,
                          labelBuilder: labelBuilder,
                          itemBuilder: itemBuilder,
                          numColumns: numColumns,
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
