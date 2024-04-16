import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/folders_and_files/collection_as_folder.dart';

class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CollectionsPageState();
}

class CollectionsPageState extends ConsumerState<CollectionsPage> {
  bool isLoading = false;
  bool excludeEmpty = true;

  @override
  Widget build(BuildContext context) => GetCollectionMultiple(
        excludeEmpty: excludeEmpty,
        buildOnData: (collections) {
          final identifier = 'FolderView Collections'
              ' excludeEmpty: $excludeEmpty';
          final galleryGroups = <GalleryGroup<Collection>>[];
          for (final rows in collections.convertTo2D(3)) {
            galleryGroups.add(GalleryGroup(rows));
          }
          return CLSimpleGalleryView(
            key: ValueKey(identifier),
            title: 'Collections',
            columns: 3,
            galleryMap: galleryGroups,
            emptyState: const EmptyState(),
            itemBuilder: (context, item, {required quickMenuScopeKey}) =>
                CollectionAsFolder(
              collection: item,
              quickMenuScopeKey: quickMenuScopeKey,
            ),
            identifier: identifier,
            onPickFiles: (BuildContext c) async => onPickFiles(
              c,
              ref,
            ),
            onCameraCapture: () {
              context.push('/camera');
            },
            onRefresh: () async {
              ref.invalidate(dbManagerProvider);
            },
          );
        },
      );
}
