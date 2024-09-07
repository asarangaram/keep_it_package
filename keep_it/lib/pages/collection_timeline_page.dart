// ignore_for_file: unused_element

import 'package:colan_services/colan_services.dart';
import 'package:colan_services/services/store_service/providers/store.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
            items: items,
            actionControl: actionControl,
            parentIdentifier:
                'Gallery View Media CollectionId: ${collection?.id}',
            onTapMedia: (
              CLMedia media, {
              required String parentIdentifier,
            }) async {
              await Navigators.openMedia(
                context,
                media.id!,
                collectionId: collectionId,
                parentIdentifier: parentIdentifier,
                actionControl: ActionControl.full(),
              );

              return true;
            },
            onPickFiles: (BuildContext c) async {
              if (c.mounted) {
                await IncomingMediaMonitor.onPickFiles(
                  c,
                  ref,
                  collection: collection,
                );
              }
            },
            onCameraCapture: ColanPlatformSupport.cameraUnsupported
                ? null
                : (ctx) =>
                    Navigators.openCamera(ctx, collectionId: collection?.id),
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
  final void Function(
    BuildContext context,
  )? onCameraCapture;
  final ActionControl actionControl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryGroups = ref.watch(groupedItemsProvider(items));

    return CLSimpleGalleryView(
      key: ValueKey(label),
      title: label,
      backButton: ColanPlatformSupport.isMobilePlatform
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CLButtonIcon.small(
                MdiIcons.arrowLeft,
                onTap: () => CLPopScreen.onPop(context),
              ),
            ),
      identifier: parentIdentifier,
      columns: 4,
      galleryMap: galleryGroups,
      emptyState: const EmptyState(),
      itemBuilder: (context, item, {required quickMenuScopeKey}) => MediaAsFile(
        media: item,
        parentIdentifier: parentIdentifier,
        onTap: () => onTapMedia(item, parentIdentifier: parentIdentifier),
        quickMenuScopeKey: quickMenuScopeKey,
        actionControl: actionControl,
      ),
      onPickFiles: onPickFiles,
      onCameraCapture: onCameraCapture,
      onRefresh: () async => ref.read(storeProvider.notifier).onRefresh(),
      selectionActions: (context, items) {
        return [
          CLMenuItem(
            title: 'Delete',
            icon: Icons.delete,
            onTap: () async {
              final confirmed = await ConfirmAction.deleteMediaMultiple(
                    context,
                    media: items,
                  ) ??
                  false;
              if (!confirmed) return confirmed;
              if (context.mounted) {
                return ref
                    .read(storeProvider.notifier)
                    .deleteMediaMultiple({...items.map((e) => e.id!)});
              }
              return null;
            },
          ),
          CLMenuItem(
            title: 'Move',
            icon: MdiIcons.imageMove,
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
            icon: MdiIcons.shareAll,
            onTap: () => Navigators.shareMediaMultiple(context, items),
          ),
          if (ColanPlatformSupport.isMobilePlatform)
            CLMenuItem(
              title: 'Pin',
              icon: MdiIcons.pin,
              onTap: () =>
                  ref.read(storeProvider.notifier).togglePinMultiple(items),
            ),
        ];
      },
    );
  }
}
