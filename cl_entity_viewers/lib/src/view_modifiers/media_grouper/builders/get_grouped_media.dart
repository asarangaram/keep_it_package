/* import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart' show StoreEntity;

import '../../src/stores/builders/w3_get_collection.dart';

import '../providers/media_grouper.dart';
import 'get_sorted_entities.dart';

class GetGroupedMedia extends ConsumerWidget {
  const GetGroupedMedia({
    required this.viewIdentifier,
    required this.builder,
    required this.incoming,
    required this.columns,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.viewableAsCollection,
    required this.storeIdentity,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final int columns;
  final List<ViewerEntityMixin> incoming;
  final String storeIdentity;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(List<ViewerEntityGroups> galleryMap) builder;
  final bool viewableAsCollection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    incoming.sort(
      (a, b) => ((a as StoreEntity).data.label?.toLowerCase() ?? '')
          .compareTo((b as StoreEntity).data.label?.toLowerCase() ?? ''),
    );
    final ids = incoming
        .map((e) => (e as StoreEntity).parentId)
        .where((e) => e != null)
        .map((e) => e!)
        .toSet()
        .toList();

    return GetCollectionsByIdList(
      storeIdentity: storeIdentity,
      ids: ids,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      builder: (collections) {
        return GetSortedEntity(
          entities: collections,
          builder: (sortedCollections) {
            final result = <ViewerEntityGroups>[];

            if (viewableAsCollection) {
              result.add(
                ViewerEntityGroups(
                  name: 'Collections',
                  galleryGroups: ref.watch(
                    groupedMediaProvider(
                      MapEntry(
                        TabIdentifier(
                          view: viewIdentifier,
                          tabId: 'Collection',
                        ),
                        sortedCollections,
                      ),
                    ),
                  ),
                ),
              );
            }
            result.add(
              ViewerEntityGroups(
                name: 'Media',
                galleryGroups: ref.watch(
                  groupedMediaProvider(
                    MapEntry(
                      TabIdentifier(view: viewIdentifier, tabId: 'Media'),
                      incoming,
                    ),
                  ),
                ),
              ),
            );

            return builder(result);
          },
        );
      },
    );
  }
}


 */
