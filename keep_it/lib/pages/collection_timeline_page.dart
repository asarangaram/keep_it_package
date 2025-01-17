/* import 'dart:developer' as dev;

import 'package:colan_services/colan_services.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../widgets/folders_and_files/media_as_file.dart';

void _log(
  dynamic message, {
  int level = 0,
  Object? error,
  StackTrace? stackTrace,
  String? name,
}) {
  dev.log(
    message.toString(),
    level: level,
    error: error,
    stackTrace: stackTrace,
    name: name ?? 'Media Builder',
  );
}

class CollectionTimeLinePage extends ConsumerWidget {
  const CollectionTimeLinePage({
    required this.collectionId,
    required this.emptyState,
    this.topWidget,
    super.key,
  });

  final int collectionId;
  final Widget? topWidget;
  final Widget emptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GetCollection(
        id: collectionId,
        errorBuilder: null,
        loadingBuilder: null,
        builder: (collection) {
          return GetMediaByCollectionId(
            collectionId: collectionId,
            errorBuilder: null,
            loadingBuilder: null,
            builder: (items) {
              _log('Found ${items.entries.length} media here');
              if (items.isEmpty) {
                return emptyState;
              }
              return TimelineView(
                parentIdentifier: 'Collection Gallery ${collection?.label}',
                items: items,
              );
            },
          );
        },
      );
}

class TimelineView extends ConsumerWidget {
  const TimelineView({
    required this.parentIdentifier,
    required this.items,
    super.key,
  });

  final String parentIdentifier;
  final CLMedias items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryMap = ref.watch(groupedItemsProvider(items.entries));

    return CLSimpleGalleryView<CLMedia>(
      identifier: parentIdentifier,
      items: items.entries,
      itemBuilder: (context, item) => MediaAsFile(
        media: item as CLMedia,
        parentIdentifier: parentIdentifier,
        onTap: () async {
          await PageManager.of(context, ref).openMedia(
            item.id!,
            collectionId: item.collectionId,
            parentIdentifier: parentIdentifier,
          );
          return true;
        },
      ),
      columns: 4,
      galleryMap: galleryMap,
    );
  }
}

/* selectionActions: (context, items) {
            return [
              CLMenuItem(
                title: 'Delete',
                icon: clIcons.deleteItem,
                onTap: () async {
                  final confirmed = await ConfirmAction.deleteMediaMultiple(
                        context,
                        ref,
                        media: items,
                      ) ??
                      false;
                  if (!confirmed) return confirmed;
                  if (context.mounted) {
                    return theStore.mediaUpdater.deleteMultiple(
                      {...items.map((e) => e.id!)},
                    );
                  }
                  return null;
                },
              ),
              CLMenuItem(
                title: 'Move',
                icon: clIcons.imageMoveAll,
                onTap: () => MediaWizardService.openWizard(
                  context,
                  ref,
                  CLSharedMedia(
                    entries: items,
                    type: UniversalMediaSource.move,
                  ),
                ),
              ),
              CLMenuItem(
                title: 'Share',
                icon: clIcons.imageShareAll,
                onTap: () => theStore.mediaUpdater.share(context, items),
              ),
              if (ColanPlatformSupport.isMobilePlatform)
                CLMenuItem(
                  title: 'Pin',
                  icon: clIcons.pinAll,
                  onTap: () => theStore.mediaUpdater.pinToggleMultiple(
                    items.map((e) => e.id).toSet(),
                  ),
                ),
            ];
          }, */
 */
