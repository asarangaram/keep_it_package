import 'package:app_loader/app_loader.dart';
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
    return CLButtonIcon.tiny(
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
        return CLButtonIcon.tiny(
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

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: CLButtonIcon.tiny(
        isEditing ? clIcons.searchOpened : clIcons.searchRequest,
        onTap: () => ref.read(filtersProvider.notifier).toggleEdit(),
      ),
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
        return CLButtonIcon.tiny(
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

class NightMode extends ConsumerWidget {
  const NightMode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(nightModeProvider);

    return CLButtonIcon.tiny(
      themeMode == ThemeMode.light ? Icons.nightlight_round : Icons.wb_sunny,
      onTap: () {
        ref.read(nightModeProvider.notifier).state =
            themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      },
    );
  }
}

final activeCollectionProvider = StateProvider<int?>((ref) {
  return null;
});
