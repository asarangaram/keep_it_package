import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/folders_and_files/collection_as_folder.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

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

            return CLSimpleGalleryView(
              key: const ValueKey(identifier),
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
              topWidget: const SearchOptions(),
              itemBuilder: (context, item) => CollectionAsFolder(
                collection: item,
              ),
              identifier: identifier,
              actions: [
                const SearchIcon(),
                ...[
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
                        await PageManager.of(context, ref).openCamera();
                        return true;
                      },
                    ),
                ].map(
                  (e) => CLButtonIcon.small(
                    e.icon,
                    onTap: e.onTap,
                  ),
                ),
              ],
              popupActionItems: [
                CLMenuItem(
                  title: 'Settings',
                  icon: clIcons.navigateSettings,
                  onTap: () async {
                    await PageManager.of(context, ref).openSettings();
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
