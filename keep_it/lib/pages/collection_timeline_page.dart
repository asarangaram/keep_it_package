import 'dart:developer' as dev;

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/navigation/providers/active_collection.dart';

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
              return TimelineView(
                label: collection?.label ?? 'All Media',
                items: items,
                collection: collection,
                parentIdentifier:
                    'Gallery View Media CollectionId: ${collection?.id}',
                emptyState: emptyState,
              );
            },
          );
        },
      );
}

class TimelineView extends ConsumerWidget {
  const TimelineView({
    required this.label,
    required this.parentIdentifier,
    required this.items,
    required this.collection,
    required this.emptyState,
    super.key,
  });
  final Widget emptyState;

  final String label;
  final String parentIdentifier;
  final CLMedias items;

  final Collection? collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreUpdater(
      builder: (theStore) {
        return MediaGalleryView(
          key: ValueKey(label),
          title: label,
          backButton: Padding(
            padding: EdgeInsets.zero,
            child: CLButtonIcon.small(
              clIcons.pagePop,
              onTap: () =>
                  ref.read(activeCollectionProvider.notifier).state = null,
            ),
          ),
          identifier: parentIdentifier,
          columns: 4,
          medias: items,
          emptyState: emptyState,
          itemBuilder: (context, item) => MediaAsFile(
            media: item,
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
                    collection: collection,
                  );
                  return true;
                },
              ),
              if (ColanPlatformSupport.cameraSupported)
                CLMenuItem(
                  title: 'Open Camera',
                  icon: clIcons.invokeCamera,
                  onTap: () async {
                    await PageManager.of(context, ref).openCamera(
                      collectionId: collection?.id,
                    );
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
          onRefresh: () async => theStore.store.reloadStore(),
          selectionActions: (context, items) {
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
          },
        );
      },
    );
  }
}
