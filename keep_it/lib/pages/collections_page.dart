import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/providers/active_collection.dart';
import '../widgets/folders_and_files/collection_as_folder.dart';
import 'collection_timeline_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const topWidget = Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: SearchOptions(),
    );
    final collectionId = ref.watch(activeCollectionProvider);
    final emptyState = EmptyState(
      menuItems: [
        if (collectionId != null)
          CLMenuItem(
            title: 'Reset',
            icon: clIcons.navigateHome,
            onTap: () async {
              ref.read(activeCollectionProvider.notifier).state = null;
              return true;
            },
          ),
        // add takeonline icon here if not online
      ],
      message: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CLText.large('Empty'),
            /* if (!isAllAvailable)  */ ...[
              SizedBox(
                height: 32,
              ),
              CLText.standard(
                'Go Online to view collections '
                'in the server',
                color: Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          topWidget,
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: (collectionId == null)
                  ? CollectionsPage(
                      emptyState: emptyState,
                    )
                  : CollectionTimeLinePage(
                      collectionId: collectionId,
                      emptyState: emptyState,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

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

            return CLSimpleGalleryView(
              key: const ValueKey(identifier),
              title: 'Collections',
              backButton: null,
              columns: 3,
              galleryMap: galleryGroups,
              emptyState: emptyState,
              topWidget: topWidget,
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
