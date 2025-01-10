import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        return CLLabel.large(collection?.label ?? 'Collections');
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
    return CLButtonIcon.small(
      clIcons.pagePop,
      onTap: () => ref.read(activeCollectionProvider.notifier).state = null,
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
