import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart' show CLEntity, GalleryGroupCLEntity;

import '../../../internal/selection_control/selection_control.dart';
import 'cl_entity_grid_view.dart';

class GalleryView extends ConsumerWidget {
  const GalleryView({
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
                        return CLEntityGridViewBuilder(
                          key: ValueKey(galleryMap),
                          galleryMap: galleryMap,
                          loadingBuilder: loadingBuilder,
                          errorBuilder: errorBuilder,
                          builder: (galleryMapL) {
                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: CLEntityGridView(
                                galleryMap: galleryMapL,
                                bannersBuilder: bannersBuilder,
                                labelBuilder: labelBuilder,
                                itemBuilder: itemBuilder,
                                columns: numColumns,
                              ),
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
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });
  final Map<String, List<GalleryGroupCLEntity<CLEntity>>> galleryMap;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function(List<GalleryGroupCLEntity<CLEntity>> items) builder;
  @override
  State<CLEntityGridViewBuilder> createState() =>
      _CLEntityGridViewBuilderState();
}

class _CLEntityGridViewBuilderState extends State<CLEntityGridViewBuilder> {
  @override
  Widget build(BuildContext context) {
    return GetCurrenViewIdentifiers(
      builder: (viewIdentifier, {required onChangeView}) {
        final String identifier;
        if (widget.galleryMap.keys.contains(viewIdentifier)) {
          identifier = viewIdentifier;
        } else {
          identifier = widget.galleryMap.keys.first;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            onChangeView(identifier);
          });
        }

        return Column(
          children: [
            if (widget.galleryMap.entries.length > 1)
              ShadTabs(
                padding: EdgeInsets.zero,
                value: identifier,
                // tabBarConstraints: BoxConstraints(maxWidth: 400),
                //contentConstraints: BoxConstraints(maxWidth: 400),
                onChanged: onChangeView,
                tabs: [
                  for (final k in widget.galleryMap.keys)
                    ShadTab(
                      value: k,
                      child: Text(k),
                    ),
                ],
              ),
            Expanded(child: widget.builder(widget.galleryMap[identifier]!)),
          ],
        );
      },
    );
  }
}

final currenViewIdentifiersProvider = StateProvider<String>((ref) {
  return 'Media';
});

class GetCurrenViewIdentifiers extends ConsumerWidget {
  const GetCurrenViewIdentifiers({required this.builder, super.key});
  final Widget Function(
    String currenViewIdentifier, {
    required void Function(String value) onChangeView,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idString = ref.watch(currenViewIdentifiersProvider);
    return builder(
      idString,
      onChangeView: (val) =>
          ref.read(currenViewIdentifiersProvider.notifier).state = val,
    );
  }
}
