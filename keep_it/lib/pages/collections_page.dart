import 'package:colan_services/colan_services.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../builders/showable_collections.dart';
import '../widgets/folders_and_files/collection_as_folder.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({
    required this.emptyState,
    this.topWidget,
    super.key,
  });
  final Widget? topWidget;
  final Widget emptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStore(
      builder: (store) {
        return GetShowableCollectionMultiple(
          loadingBuilder: () => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: null,
          builder: (
            collections,
            galleryGroups, {
            required isAllAvailable,
          }) {
            const identifier = 'FolderView Collections';
            if (galleryGroups.isEmpty) {
              return emptyState;
            }
            return CLSimpleGalleryView(
              key: const ValueKey(identifier),
              columns: 3,
              galleryMap: galleryGroups,
              itemBuilder: (context, item) => CollectionAsFolder(
                collection: item,
              ),
              identifier: identifier,
            );
          },
        );
      },
    );
  }
}
