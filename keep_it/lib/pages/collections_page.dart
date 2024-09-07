import 'package:colan_services/colan_services.dart';
import 'package:colan_services/services/store_service/providers/store.dart';
import 'package:colan_widgets/colan_widgets.dart';
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
  bool excludeEmpty = true;

  @override
  Widget build(BuildContext context) => GetStore(
        loadingBuilder: () => const Center(
          child: CircularProgressIndicator(),
        ),
        builder: (theStore) {
          final collections =
              theStore.getCollections(excludeEmpty: excludeEmpty);

          final staleMedia = theStore.getStaleMedia();
          final identifier = 'FolderView Collections'
              ' excludeEmpty: $excludeEmpty';
          final galleryGroups = <GalleryGroup<Collection>>[];
          for (final rows in collections.convertTo2D(3)) {
            galleryGroups.add(
              GalleryGroup(
                rows,
                label: null,
                groupIdentifier: 'Collections',
                chunkIdentifier: 'Collections',
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: CLSimpleGalleryView(
                  key: ValueKey(identifier),
                  title: 'Collections',
                  backButton: null,
                  columns: 3,
                  galleryMap: galleryGroups,
                  emptyState: const EmptyState(),
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
                  onPickFiles: (BuildContext c) async =>
                      IncomingMediaMonitor.onPickFiles(
                    c,
                    ref,
                  ),
                  onCameraCapture: ColanPlatformSupport.cameraUnsupported
                      ? null
                      : Navigators.openCamera,
                  onRefresh: () async =>
                      ref.read(storeProvider.notifier).onRefresh(),
                ),
              ),
              if (staleMedia.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: CLText.standard(
                            'You have unclassified media. '
                            '(${staleMedia.length})',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => MediaWizardService.openWizard(
                          context,
                          ref,
                          CLSharedMedia(
                            entries: staleMedia,
                            type: UniversalMediaSource.unclassified,
                          ),
                        ),
                        child: const CLText.small('Show Now'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      );
}
