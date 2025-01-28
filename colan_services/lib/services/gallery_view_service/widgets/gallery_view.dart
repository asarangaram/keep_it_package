import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart' show CLEntity, GalleryGroupCLEntity;

import '../../../internal/selection_control/selection_control.dart';
import 'cl_entity_grid_view.dart';
import 'grouper.dart';

class GalleryView extends StatelessWidget {
  const GalleryView({
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.itemBuilder,
    required this.numColumns,
    required this.onGroupItems,
    required this.selectionMode,
    required this.onChangeSelectionMode,
    required this.emptyWidget,
    required this.selectionActionsBuilder,
    super.key,
    this.filterDisabled = false,
    this.onSelectionChanged,
  });
  final List<CLEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function(
    BuildContext,
    CLEntity,
  ) itemBuilder;
  final int numColumns;
  final Future<Map<String, List<GalleryGroupCLEntity<CLEntity>>>> Function(
    List<CLEntity> entities, {
    required GroupTypes method,
    required bool groupAsCollection,
  }) onGroupItems;
  final bool selectionMode;
  final void Function({required bool enable}) onChangeSelectionMode;
  final Widget emptyWidget;
  final List<CLMenuItem> Function(BuildContext, List<CLEntity>)?
      selectionActionsBuilder;
  final void Function(List<CLEntity>)? onSelectionChanged;
  final bool filterDisabled;
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
          ? emptyWidget
          : SelectionControl(
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
                      errorBuilder: errorBuilder,
                      loadingBuilder: loadingBuilder,
                      incoming: filterred,
                      columns: numColumns,
                      getGrouped: onGroupItems,
                      builder: (galleryMap /* numColumns */) {
                        return CLEntityGridViewBuilder(
                          galleryMap: galleryMap,
                          builder: (galleryMapL) {
                            return CLEntityGridView(
                              galleryMap: galleryMapL,
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
                );
              },
            ),
    );
  }
}

class CLEntityGridViewBuilder extends StatefulWidget {
  const CLEntityGridViewBuilder({
    required this.builder,
    required this.galleryMap,
    super.key,
  });
  final Map<String, List<GalleryGroupCLEntity<CLEntity>>> galleryMap;
  final Widget Function(List<GalleryGroupCLEntity<CLEntity>> items) builder;
  @override
  State<CLEntityGridViewBuilder> createState() =>
      _CLEntityGridViewBuilderState();
}

class _CLEntityGridViewBuilderState extends State<CLEntityGridViewBuilder> {
  late String currTap;
  @override
  void initState() {
    currTap = widget.galleryMap.keys.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.galleryMap.entries.length == 1) {
      return widget.builder(widget.galleryMap.values.first);
    }
    return Column(
      children: [
        ShadTabs(
          value: currTap,
          // tabBarConstraints: BoxConstraints(maxWidth: 400),
          //contentConstraints: BoxConstraints(maxWidth: 400),
          onChanged: (val) {
            setState(() {
              currTap = val;
            });
          },
          tabs: [
            for (final k in widget.galleryMap.keys)
              ShadTab(
                value: k,
                child: Text(k),
              ),
          ],
        ),
        Expanded(child: widget.builder(widget.galleryMap[currTap]!)),
      ],
    );
  }
}
