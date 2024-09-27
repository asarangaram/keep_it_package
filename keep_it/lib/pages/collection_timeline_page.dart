import 'package:colan_services/colan_services.dart';
import 'package:colan_services/internal/extensions/list.dart';
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
  Widget build(BuildContext context, WidgetRef ref) => GetStore(
        builder: (theStore) {
          final collection = theStore.getCollectionById(collectionId);
          final items = theStore.getMediaByCollectionId(collectionId);
          return TimeLineView(
            label: collection?.label ?? 'All Media',
            items: items.galleryMap,
            collection: collection,
            actionControl: actionControl,
            parentIdentifier:
                'Gallery View Media CollectionId: ${collection?.id}',
            onTapMedia: (
              CLMedia media, {
              required String parentIdentifier,
            }) async {
              if (theStore.hasMediaFile(media)) {
                await Navigators.openMedia(
                  context,
                  media.id!,
                  collectionId: collectionId,
                  parentIdentifier: parentIdentifier,
                  actionControl: ActionControl.full(),
                );

                return true;
              }

              return false;
            },
          );
        },
      );
}

class TimeLineView extends ConsumerWidget {
  const TimeLineView({
    required this.label,
    required this.parentIdentifier,
    required this.items,
    required this.onTapMedia,
    required this.actionControl,
    required this.collection,
    super.key,
  });

  final String label;
  final String parentIdentifier;
  final List<GalleryGroup<CLMedia>> items;
  final Future<bool?> Function(
    CLMedia media, {
    required String parentIdentifier,
  }) onTapMedia;

  final ActionControl actionControl;
  final Collection? collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStore(
      builder: (theStore) {
        return CLSimpleGalleryView(
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
          galleryMap: items,
          emptyState: const EmptyState(),
          itemBuilder: (context, item, {required quickMenuScopeKey}) =>
              MediaAsFile(
            media: item,
            parentIdentifier: parentIdentifier,
            onTap: () => onTapMedia(item, parentIdentifier: parentIdentifier),
            quickMenuScopeKey: quickMenuScopeKey,
            actionControl: actionControl,
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
          onRefresh: () async => theStore.onRefresh(),
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
                    items.map((e) => e.id).nonNullableList.toSet(),
                  ),
                ),
            ];
          },
        );
      },
    );
  }
}
