import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeadingAction extends ConsumerWidget {
  const LeadingAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCollection = ref.watch(activeCollectionProvider);
    if (activeCollection == null) {
      return const SizedBox.shrink();
    }
    return CLButtonIcon.standard(
      clIcons.pagePop,
      onTap: () {
        ref.read(activeCollectionProvider.notifier).state = null;
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

class SearchIcon extends ConsumerWidget {
  const SearchIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(filtersProvider.select((e) => e.editing));

    return CLButtonIcon.small(
      isEditing ? clIcons.searchOpened : clIcons.searchRequest,
      onTap: () => ref.read(filtersProvider.notifier).toggleEdit(),
    );
  }
}

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

final activeCollectionProvider = StateProvider<int?>((ref) {
  return null;
});
