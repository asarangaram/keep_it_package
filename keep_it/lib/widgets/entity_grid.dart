import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/when_empty.dart';

import 'package:store/store.dart';

import '../builders/grouper.dart';
import '../navigation/providers/active_collection.dart';
import 'cl_entity_grid_view.dart';
import 'folders_and_files/collection_as_folder.dart';
import 'folders_and_files/media_as_file.dart';

class EntityGrid extends ConsumerWidget {
  const EntityGrid({
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });
  final List<CLEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identifier = ref.watch(mainPageIdentifierProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
      ) =>
          FadeTransition(opacity: animation, child: child),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: entities.isEmpty
            ? const WhenEmpty()
            : SelectionControl(
                itemBuilder: (context, item) => switch (item.runtimeType) {
                  Collection => CollectionAsFolder(
                      collection: item as Collection,
                      onTap: () {
                        ref
                            .read(
                              activeCollectionProvider.notifier,
                            )
                            .state = item.id;
                      },
                    ),
                  CLMedia => MediaAsFile(
                      media: item as CLMedia,
                      parentIdentifier: identifier,
                      onTap: () async {
                        await PageManager.of(context, ref).openMedia(
                          item.id!,
                          collectionId: item.collectionId,
                          parentIdentifier: identifier,
                        );
                        return true;
                      },
                    ),
                  _ => throw UnimplementedError(),
                },
                labelBuilder: (context, gallery) {
                  return gallery.label == null
                      ? null
                      : CLText.large(
                          gallery.label!,
                          textAlign: TextAlign.start,
                        );
                },
                builder: ({required itemBuilder, required labelBuilder}) {
                  return GetFilterredMedia(
                    errorBuilder: errorBuilder,
                    loadingBuilder: loadingBuilder,
                    incoming: entities,
                    builder: (filterred) {
                      return filterred.isEmpty
                          ? Center(
                              child: FilterCount(
                                total: entities.length,
                                filterred: filterred.length,
                              ),
                            )
                          : GetGroupedMedia(
                              incoming: filterred,
                              columns: 4,
                              builder: (galleryMap) {
                                return CLEntityGridView(
                                  identifier: identifier,
                                  galleryMap: galleryMap,
                                  topWidget: Align(
                                    alignment: Alignment.centerRight,
                                    child: FilterCount(
                                      total: entities.length,
                                      filterred: filterred.length,
                                    ),
                                  ),
                                  labelBuilder: labelBuilder,
                                  itemBuilder: itemBuilder,
                                  columns: 4,
                                );
                              },
                            );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class FilterCount extends ConsumerWidget {
  const FilterCount({required this.total, required this.filterred, super.key});
  final int total;
  final int filterred;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topMsg = (filterred < total)
        ? ' $filterred out of '
            '$total is Shown.'
        : null;
    if (topMsg == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.onSurface,
        child: CLText.tiny(
          topMsg,
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
      ),
    );
  }
}

class SelectionControl extends ConsumerWidget {
  const SelectionControl({
    required this.builder,
    required this.itemBuilder,
    required this.labelBuilder,
    super.key,
  });
  final Widget Function(BuildContext, CLEntity) itemBuilder;
  final Widget? Function(
    BuildContext context,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final Widget Function({
    required Widget Function(BuildContext, CLEntity) itemBuilder,
    required Widget? Function(
      BuildContext context,
      GalleryGroupCLEntity<CLEntity> gallery,
    ) labelBuilder,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      child: builder(itemBuilder: itemBuilder, labelBuilder: labelBuilder),
    );
  }
}
