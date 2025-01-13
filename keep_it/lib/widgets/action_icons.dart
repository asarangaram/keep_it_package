import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../navigation/providers/active_collection.dart';

class MainViewTitle extends ConsumerWidget {
  const MainViewTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    return GetCollection(
      id: collectionId,
      loadingBuilder: SizedBox.shrink,
      errorBuilder: (p0, p1) => const SizedBox.shrink(),
      builder: (collection) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (collectionId != null)
                CLButtonIcon.small(
                  clIcons.pagePop,
                  onTap: () =>
                      ref.read(activeCollectionProvider.notifier).state = null,
                ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    collection?.label.capitalizeFirstLetter() ?? 'Collections',
                    style: Theme.of(context).textTheme.headlineLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MainViewLeading extends ConsumerWidget {
  const MainViewLeading({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    if (collectionId == null) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(220),
        shape: const CircleBorder(), // Oval shape
      ),
      child: CLButtonIcon.small(
        clIcons.pagePop,
        onTap: () => ref.read(activeCollectionProvider.notifier).state = null,
      ),
    );
  }
}

class SelectControlIcon extends ConsumerWidget {
  const SelectControlIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final identifier = ref.watch(mainPageIdentifierProvider);
    if (collectionId == null) {
      return const SizedBox.shrink();
    }
    final selectionMode = ref.watch(selectModeProvider(identifier));

    return CLButtonText.small(
      selectionMode ? 'Done' : 'Select',
      onTap: () {
        ref.watch(selectModeProvider(identifier).notifier).state =
            !selectionMode;
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

class ImportIcons extends ConsumerWidget {
  const ImportIcons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(activeCollectionProvider);
    return GetCollection(
      id: id,
      errorBuilder: (_, __) => const SizedBox.shrink(),
      loadingBuilder: () => const SizedBox.shrink(),
      builder: (collection) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (id == null) const StaleMediaIndicator(),
            const ServerControl(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      child: IconButton(
                        onPressed: () {
                          IncomingMediaMonitor.onPickFiles(
                            context,
                            ref,
                            collection: collection,
                          );
                        },
                        icon: Icon(clIcons.insertItem),
                      ),
                    ),
                  ),
                ),
                if (ColanPlatformSupport.cameraSupported) ...[
                  const SizedBox(
                    width: 16,
                  ),
                  // Right FAB
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: CircleAvatar(
                        child: IconButton(
                          onPressed: () {
                            PageManager.of(context, ref)
                                .openCamera(collectionId: collection?.id);
                          },
                          icon: Icon(
                            clIcons.camera,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class ExtraActions extends ConsumerWidget {
  const ExtraActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    return PopupMenuButton<CLMenuItem>(
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
    );
  }
}
