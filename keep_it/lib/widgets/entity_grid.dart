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
import 'selection_control.dart';

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
    const numColumns = 3;
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
      child: entities.isEmpty
          ? const WhenEmpty()
          : SelectionControl(
              incoming: entities,
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
                      builder: (galleryMap /* numColumns */) {
                        return CLEntityGridView(
                          identifier: identifier,
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
