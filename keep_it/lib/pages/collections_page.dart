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

  Widget loadingBuilder() => const SizedBox.shrink();

  Widget errorBuilder(p0, p1) => const SizedBox.shrink();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const topWidget = Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: SearchOptions(),
    );
    final collectionId = ref.watch(activeCollectionProvider);
    const emptyState = WhenEmpty();
    final actions = [
      const SearchIcon(),
      const FileSelectAction(),
      if (ColanPlatformSupport.cameraSupported) const CameraAction(),
    ];
    final popupActionItems = [
      CLMenuItem(
        title: 'Settings',
        icon: clIcons.navigateSettings,
        onTap: () async {
          await PageManager.of(context, ref).openSettings();
          return true;
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: GetCollection(
          id: collectionId,
          loadingBuilder: SizedBox.shrink,
          errorBuilder: (p0, p1) => const SizedBox.shrink(),
          builder: (collection) {
            return CLLabel.large(collection?.label ?? 'Collections');
          },
        ),
        leading: collectionId == null
            ? null
            : CLButtonIcon.small(
                clIcons.pagePop,
                onTap: () =>
                    ref.read(activeCollectionProvider.notifier).state = null,
              ),
        automaticallyImplyLeading: false,
        actions: [
          if (actions.isNotEmpty)
            ...actions.map(
              (e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: e,
              ),
            ),
          if (popupActionItems.isNotEmpty)
            PopupMenuButton<CLMenuItem>(
              onSelected: (CLMenuItem item) {
                item.onTap?.call();
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<CLMenuItem>>[
                  for (final item in popupActionItems) ...[
                    PopupMenuItem<CLMenuItem>(
                      value: item,
                      child: ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.title),
                      ),
                    ),
                  ],
                ];
              },
              child: const Icon(Icons.more_vert),
            ),
        ],
      ),
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
                  ? const CollectionsPage(
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

class WhenEmpty extends ConsumerWidget {
  const WhenEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    return EmptyState(
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
              actions: const [],
              onRefresh: () async => store.reloadStore(),
            );
          },
        );
      },
    );
  }
}

class FileSelectAction extends ConsumerWidget {
  const FileSelectAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(activeCollectionProvider);

    return GetCollection(
      id: id,
      errorBuilder: (_, __) => const SizedBox.shrink(),
      loadingBuilder: () => const SizedBox.shrink(),
      builder: (collection) {
        return CLButtonIcon.standard(
          clIcons.insertItem,
          onTap: () {
            IncomingMediaMonitor.onPickFiles(
              context,
              ref,
              collection: collection,
            );
          },
        );
      },
    );
  }
}

/* class SearchIcon extends ConsumerWidget {
  const SearchIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(filtersProvider.select((e) => e.editing));

    return CLButtonIcon.small(
      isEditing ? clIcons.searchOpened : clIcons.searchRequest,
      onTap: () => ref.read(filtersProvider.notifier).toggleEdit(),
    );
  }
} */

class CameraAction extends ConsumerWidget {
  const CameraAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(activeCollectionProvider);

    return GetCollection(
      id: id,
      errorBuilder: (_, __) => const SizedBox.shrink(),
      loadingBuilder: () => const SizedBox.shrink(),
      builder: (collection) {
        return CLButtonIcon.standard(
          clIcons.insertItem,
          onTap: () {
            PageManager.of(context, ref)
                .openCamera(collectionId: collection?.id);
          },
        );
      },
    );
  }
}
