import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/appbar_icons.dart';
import '../widgets/folders_and_files/collection_as_folder.dart';
import '../widgets/page_template.dart';
import 'collection_timeline_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    return GetCollection(
      id: collectionId,
      builder: (collection) {
        return CLPage(
          actions: [
            const NightMode(),
            const SearchIcon(),
            const FileSelectAction(),
            if (ColanPlatformSupport.cameraSupported) const CameraAction(),
          ],
          popupMenuItems: [
            CLMenuItem(
              title: 'Settings',
              icon: clIcons.navigateSettings,
              onTap: () async {
                await PageManager.of(context, ref).openSettings();
                return true;
              },
            ),
          ],
          title: 'Collections',
          leading: collectionId == null ? null : const LeadingAction(),
          children: const [
            SearchOptions(),
          ],
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: MainView(),
          ),
        );
      },
    );
  }
}

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    if (collectionId == null) {
      return const CollectionsView();
    }
    return CollectionTimeLinePage(collectionId: collectionId);
  }
}

class CollectionsView extends ConsumerWidget {
  const CollectionsView({super.key});

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
              backButton: null,
              columns: 3,
              galleryMap: galleryGroups,
              emptyState: const WhenNoCollection(),
              itemBuilder: (context, item) => CollectionAsFolder(
                collection: item,
              ),
              identifier: identifier,
              onRefresh: () async => store.reloadStore(),
              actions: const [],
            );
          },
        );
      },
    );
  }
}

class WhenNoCollection extends StatelessWidget {
  const WhenNoCollection({super.key, this.isAllAvailable = false});
  final bool isAllAvailable;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
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
    );
  }
}
