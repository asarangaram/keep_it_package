// ignore_for_file: unused_element

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/folders_and_files/media_as_file.dart';
import '../widgets/preview.dart';
import '../widgets/store_manager.dart';

class CollectionTimeLinePage extends ConsumerWidget {
  const CollectionTimeLinePage({
    required this.collectionId,
    required this.actionControl,
    super.key,
  });

  final int collectionId;
  final ActionControl actionControl;

  @override
  Widget build(BuildContext context, WidgetRef ref) => StoreManager(
        builder: ({required storeAction}) {
          return GetCollection(
            id: collectionId,
            buildOnData: (collection) => GetMediaByCollectionId(
              collectionId: collectionId,
              buildOnData: (items) => TimeLineView(
                label: collection?.label ?? 'All Media',
                items: items,
                actionControl: actionControl,
                parentIdentifier:
                    'Gallery View Media CollectionId: ${collection?.id}',
                onTapMedia: (
                  CLMedia media, {
                  required String parentIdentifier,
                }) async {
                  await storeAction.openMedia(
                    media.id!,
                    collectionId: collectionId,
                    parentIdentifier: parentIdentifier,
                    actionControl: ActionControl.full(),
                  );

                  return true;
                },
                onPickFiles: (BuildContext c) async {
                  if (c.mounted) {
                    await onPickFiles(
                      c,
                      ref,
                      collection: collection,
                    );
                  }
                },
                onCameraCapture: ColanPlatformSupport.cameraUnsupported
                    ? null
                    : () =>
                        storeAction.openCamera(collectionId: collection?.id),
              ),
            ),
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
    this.onPickFiles,
    this.onCameraCapture,
    super.key,
  });

  final String label;
  final String parentIdentifier;
  final List<CLMedia> items;
  final Future<bool?> Function(
    CLMedia media, {
    required String parentIdentifier,
  }) onTapMedia;
  final void Function(BuildContext context)? onPickFiles;
  final void Function()? onCameraCapture;
  final ActionControl actionControl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryGroups = ref.watch(groupedItemsProvider(items));

    return StoreManager(
      builder: ({required storeAction}) {
        return CLSimpleGalleryView(
          key: ValueKey(label),
          title: label,
          identifier: parentIdentifier,
          columns: 4,
          galleryMap: galleryGroups,
          emptyState: const EmptyState(),
          itemBuilder: (context, item, {required quickMenuScopeKey}) => Hero(
            tag: '$parentIdentifier /item/${item.id}',
            child: MediaAsFile(
              media: item,
              getPreview: (media) => Preview(media: media),
              onTap: () => onTapMedia(item, parentIdentifier: parentIdentifier),
              quickMenuScopeKey: quickMenuScopeKey,
              actionControl: actionControl,
            ),
          ),
          onPickFiles: onPickFiles,
          onCameraCapture: onCameraCapture,
          onRefresh: () async => ref.invalidate(dbManagerProvider),
          selectionActions: (context, items) {
            return [
              CLMenuItem(
                title: 'Delete',
                icon: Icons.delete,
                onTap: () async {
                  return ConfirmAction.deleteMediaMultiple(
                    context,
                    media: items,
                    getPreview: (media) => Preview(
                      media: media,
                    ),
                    onConfirm: () => storeAction.delete(items, confirmed: true),
                  );
                },
              ),
              CLMenuItem(
                title: 'Move',
                icon: MdiIcons.imageMove,
                onTap: () =>
                    storeAction.openWizard(items, UniversalMediaSource.move),
              ),
              CLMenuItem(
                title: 'Share',
                icon: MdiIcons.shareAll,
                onTap: () => storeAction.share(items),
              ),
              if (ColanPlatformSupport.isMobilePlatform)
                CLMenuItem(
                  title: 'Pin',
                  icon: MdiIcons.pin,
                  onTap: () => storeAction.togglePin(items),
                ),
            ];
          },
        );
      },
    );
  }
}
