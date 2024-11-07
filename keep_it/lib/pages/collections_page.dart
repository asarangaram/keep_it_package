import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../widgets/folders_and_files/collection_as_folder.dart';

class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CollectionsPageState();
}

class CollectionsPageState extends ConsumerState<CollectionsPage> {
  bool isLoading = false;
  bool excludeEmpty = false;

  @override
  Widget build(BuildContext context) {
    return GetStore(
      builder: (store) {
        return GetShowableCollectionMultiple(
          loadingBuilder: () => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: null,
          builder: (
            collections,
            visibleCollections, {
            required isAllAvailable,
          }) {
            final identifier = 'FolderView Collections'
                ' excludeEmpty: $excludeEmpty';
            final galleryGroups = <GalleryGroup<Collection>>[];

            for (final rows in visibleCollections.entries.convertTo2D(3)) {
              galleryGroups.add(
                GalleryGroup(
                  rows,
                  label: null,
                  groupIdentifier: 'Collections',
                  chunkIdentifier: 'Collections',
                ),
              );
            }
            return CLSimpleGalleryView(
              key: ValueKey(identifier),
              title: 'Collections',
              backButton: null,
              columns: 3,
              galleryMap: galleryGroups,
              emptyState: EmptyState(
                message: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CLText.large('Empty'),
                      if (!isAllAvailable) ...[
                        const SizedBox(
                          height: 32,
                        ),
                        const CLText.standard(
                          'Go Online to view collections '
                          'in the server',
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              itemBuilder: (
                context,
                item, {
                required quickMenuScopeKey,
              }) =>
                  CollectionAsFolder(
                collection: item,
                quickMenuScopeKey: quickMenuScopeKey,
              ),
              identifier: identifier,
              actionMenu: [
                CLMenuItem(
                  title: 'Select File',
                  icon: clIcons.insertItem,
                  onTap: () async {
                    await IncomingMediaMonitor.onPickFiles(
                      context,
                      ref,
                    );
                    return true;
                  },
                ),
                if (ColanPlatformSupport.cameraSupported)
                  CLMenuItem(
                    title: 'Open Camera',
                    icon: clIcons.invokeCamera,
                    onTap: () async {
                      await Navigators.openCamera(context);
                      return true;
                    },
                  ),
              ],
              onRefresh: () async => store.reloadStore(),
            );
          },
        );
      },
    );
  }
}
