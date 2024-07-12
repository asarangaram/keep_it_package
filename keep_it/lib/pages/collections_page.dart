import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/store_manager.dart';
import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/folders_and_files/collection_as_folder.dart';
import '../widgets/preview.dart';

class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CollectionsPageState();
}

class CollectionsPageState extends ConsumerState<CollectionsPage> {
  bool isLoading = false;
  bool excludeEmpty = true;

  @override
  Widget build(BuildContext context) => StoreManager(
        builder: ({required storeAction}) {
          return Column(
            children: [
              Expanded(
                child: GetCollectionMultiple(
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
                      itemBuilder: (
                        context,
                        item, {
                        required quickMenuScopeKey,
                      }) =>
                          CollectionAsFolder(
                        collection: item,
                        quickMenuScopeKey: quickMenuScopeKey,
                        getPreview: (media) => Preview(media: media),
                      ),
                      identifier: identifier,
                      onPickFiles: (BuildContext c) async => onPickFiles(
                        c,
                        ref,
                      ),
                      onCameraCapture: ColanPlatformSupport.cameraUnsupported
                          ? null
                          : () => storeAction.openCamera(),
                      onRefresh: () async => ref.invalidate(dbManagerProvider),
                    );
                  },
                ),
              ),
              GetStaleMedia(
                buildOnData: (media) {
                  if (media.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: CLText.standard(
                              'You have unclassified media. (${media.length})',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => storeAction.openWizard(
                            media,
                            UniversalMediaSource.unclassified,
                          ),
                          child: const CLText.small('Show Now'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
}
