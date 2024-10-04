import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../widgets/folders_and_files/media_as_file.dart';

class CollectionTimeLinePage extends ConsumerWidget {
  const CollectionTimeLinePage({
    required this.collectionId,
    required this.actionControl,
    super.key,
  });

  final int collectionId;
  final ActionControl actionControl;

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
              log('Found ${items.entries.length} media here');
              return TimelineView(
                label: collection?.label ?? 'All Media',
                items: items,
                collection: collection,
                actionControl: actionControl,
                parentIdentifier:
                    'Gallery View Media CollectionId: ${collection?.id}',
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
    required this.actionControl,
    required this.collection,
    super.key,
  });

  final String label;
  final String parentIdentifier;
  final CLMedias items;

  final ActionControl actionControl;
  final Collection? collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreUpdater(
      builder: (theStore) {
        return MediaGalleryView(
          key: ValueKey(label),
          title: label,
          backButton: ColanPlatformSupport.isMobilePlatform
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CLButtonIcon.small(
                    clIcons.pagePop,
                    onTap: () => CLPopScreen.onPop(context),
                  ),
                ),
          identifier: parentIdentifier,
          columns: 4,
          medias: items,
          emptyState: const EmptyState(),
          itemBuilder: (context, item, {required quickMenuScopeKey}) =>
              GetMediaUri(
            id: item.id!,
            builder: (uri) {
              return MediaAsFile(
                media: item,
                parentIdentifier: parentIdentifier,
                onTap: uri == null
                    ? null
                    : () async {
                        await Navigators.openMedia(
                          context,
                          item.id!,
                          collectionId: item.collectionId,
                          parentIdentifier: parentIdentifier,
                          actionControl: ActionControl.full(),
                        );
                        return true;
                      },
                quickMenuScopeKey: quickMenuScopeKey,
                actionControl: actionControl,
              );
            },
          ),
          actionMenu: [
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
                  await Navigators.openCamera(
                    context,
                    collectionId: collection?.id,
                  );
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
                        media: items,
                      ) ??
                      false;
                  if (!confirmed) return confirmed;
                  if (context.mounted) {
                    return theStore.deleteMediaMultipleById(
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
                onTap: () => theStore.shareMedia(context, items),
              ),
              if (ColanPlatformSupport.isMobilePlatform)
                CLMenuItem(
                  title: 'Pin',
                  icon: clIcons.pinAll,
                  onTap: () => theStore.togglePinMultipleById(
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
