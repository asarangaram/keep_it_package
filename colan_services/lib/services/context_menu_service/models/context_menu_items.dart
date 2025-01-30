import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:content_store/extensions/ext_cldirectories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

import '../../basic_page_service/widgets/dialogs.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../gallery_view_service/widgets/collection_editor.dart';
import '../../media_wizard_service/media_wizard_service.dart';

@immutable
class ContextMenuItems {
  const ContextMenuItems({
    required this.name,
    required this.assetPath,
    required this.onEdit,
    required this.onMove,
    required this.onShare,
    required this.onPin,
    required this.onDelete,
    required this.onDeleteLocalCopy,
    required this.onKeepOffline,
    required this.onUpload,
    required this.onDeleteServerCopy,
    required this.infoMap,
  });
  factory ContextMenuItems.ofCollection(
    BuildContext context,
    WidgetRef ref, {
    required Collection collection,
    required bool hasOnlineService,
    required StoreUpdater theStore,
    ValueGetter<Future<bool?> Function()?>? onEdit,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onDelete,
    ValueGetter<Future<bool?> Function()?>? onDeleteLocalCopy,
    ValueGetter<Future<bool?> Function()?>? onKeepOffline,
    ValueGetter<Future<bool?> Function()?>? onUpload,
    ValueGetter<Future<bool?> Function()?>? onDeleteServerCopy,
  }) {
    final onEdit0 = onEdit != null
        ? onEdit()
        : () async {
            final updated = await CollectionEditor.popupDialog(
              context,
              ref,
              collection: collection,
            );
            if (updated != null && context.mounted) {
              await theStore.collectionUpdater.update(updated, isEdited: true);
            }

            return true;
          };
    final onMove0 = onMove?.call();
    final onShare0 = onShare?.call();

    final onDelete0 = onDelete != null
        ? onDelete()
        : () async {
            final confirmed = await DialogService.deleteCollection(
                  context,
                  collection: collection,
                ) ??
                false;
            if (!confirmed) return confirmed;
            if (context.mounted) {
              return theStore.collectionUpdater.delete(collection.id!);
            }
            return false;
          };
    final onDeleteLocalCopy0 = onDeleteLocalCopy != null
        ? onDeleteLocalCopy()
        : () async {
            if (collection.haveItOffline && collection.hasServerUID) {
              final serverNotifier = ref.read(serverProvider.notifier);
              final updater = await serverNotifier.storeUpdater;

              await updater.collectionUpdater
                  .upsert(collection.copyWith(haveItOffline: false));
              final media = await updater.store.reader
                  .getMediaByCollectionId(collection.id!);
              for (final m in media) {
                await theStore.mediaUpdater
                    .deleteLocalCopy(m, haveItOffline: () => null);
              }
              serverNotifier.instantSync();
            }
            return true;
          };
    final onKeepOffline0 = hasOnlineService
        ? onKeepOffline != null
            ? onKeepOffline()
            : () async {
                if (!collection.haveItOffline && collection.hasServerUID) {
                  final serverNotifier = ref.read(serverProvider.notifier);
                  final updater = await serverNotifier.storeUpdater;

                  await updater.collectionUpdater
                      .upsert(collection.copyWith(haveItOffline: true));
                  final media = await updater.store.reader
                      .getMediaByCollectionId(collection.id!);
                  for (final m in media) {
                    await updater.mediaUpdater.update(
                      m,
                      haveItOffline: () => null,
                      isEdited: false,
                    );
                  }
                  updater.store.reloadStore();
                  serverNotifier.instantSync();
                }
                return true;
              }
        : null;
    final onUpload0 = hasOnlineService
        ? onUpload != null
            ? onUpload()
            : () async {
                await theStore.collectionUpdater.upsert(
                  collection.copyWith(serverUID: () => -1, isEdited: true),
                );
                ref.read(serverProvider.notifier).instantSync();

                return true;
              }
        : null;
    final onDeleteServerCopy0 = onDeleteServerCopy?.call();

    return ContextMenuItems(
      name: collection.label,
      assetPath: collection.serverUID == null
          ? 'assets/icon/not_on_server.png'
          : 'assets/icon/cloud_on_lan_128px_color.png',
      onEdit:
          CLMenuItem(title: 'Edit', icon: clIcons.imageEdit, onTap: onEdit0),
      onMove:
          CLMenuItem(title: 'Move', icon: clIcons.imageMove, onTap: onMove0),
      onShare:
          CLMenuItem(title: 'Share', icon: clIcons.imageShare, onTap: onShare0),
      onPin: CLMenuItem(
        title: 'Pin',
        icon: clIcons.pin,
      ),
      onDelete: CLMenuItem(
        title: 'Delete',
        icon: clIcons.imageDelete,
        onTap: onDelete0,
      ),
      onDeleteLocalCopy: CLMenuItem(
        title: 'Remove downloads',
        icon: Icons.download_done_sharp,
        onTap: onDeleteLocalCopy0,
      ),
      onKeepOffline: CLMenuItem(
        title: 'Download',
        icon: Icons.download_sharp,
        onTap: onKeepOffline0,
      ),
      onUpload:
          CLMenuItem(title: 'Upload', icon: Icons.upload, onTap: onUpload0),
      onDeleteServerCopy: CLMenuItem(
        title: 'Permanently Delete',
        icon: Icons.remove,
        onTap: onDeleteServerCopy0,
      ),
      infoMap: collection.toMapForDisplay(),
    );
  }
  factory ContextMenuItems.ofMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia media,
    required Collection parentCollection,
    required bool hasOnlineService,
    required StoreUpdater theStore,
    ValueGetter<Future<bool?> Function()?>? onEdit,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onPin,
    ValueGetter<Future<bool?> Function()?>? onDelete,
    ValueGetter<Future<bool?> Function()?>? onDeleteLocalCopy,
    ValueGetter<Future<bool?> Function()?>? onKeepOffline,
    ValueGetter<Future<bool?> Function()?>? onUpload,
    ValueGetter<Future<bool?> Function()?>? onDeleteServerCopy,
  }) {
    final ac = ActionControl.onGetMediaActionControl(media);

    final onMove0 = ac.onMove(
      onMove != null
          ? onMove()
          : () => MediaWizardService.openWizard(
                context,
                ref,
                CLSharedMedia(
                  entries: [media],
                  type: UniversalMediaSource.move,
                ),
              ),
    );

    final onEdit0 = ac.onEdit(
      onEdit != null
          ? onEdit()
          : () async {
              await PageManager.of(context).openEditor(media);
              return true;
            },
    );

    final onShare0 = ac.onShare(
      onShare != null
          ? onShare()
          : () => theStore.mediaUpdater.share(context, [media]),
    );
    final onDelete0 = ac.onDelete(
      onDelete != null
          ? onDelete()
          : () async => theStore.mediaUpdater.delete(media.id!),
    );
    final onPin0 = ac.onPin(
      onPin != null
          ? onPin()
          : media.isMediaLocallyAvailable
              ? () async => theStore.mediaUpdater.pinToggleMultiple(
                    {media.id},
                    onGetPath: (media) {
                      if (media.isMediaLocallyAvailable) {
                        return theStore.directories.getMediaAbsolutePath(media);
                      }

                      return null;
                    },
                  )
              : null,
    );
    final canSync = hasOnlineService;
    final canDeleteLocalCopy = canSync &&
        parentCollection.haveItOffline &&
        media.hasServerUID &&
        media.isMediaCached;
    final haveItOffline = switch (media.haveItOffline) {
      null => parentCollection.haveItOffline,
      true => true,
      false => false
    };
    final canDownload =
        canSync && media.hasServerUID && !media.isMediaCached && haveItOffline;

    final onDeleteLocalCopy0 = canDeleteLocalCopy
        ? onDeleteLocalCopy != null
            ? onDeleteLocalCopy()
            : () async =>
                ref.read(serverProvider.notifier).onDeleteMediaLocalCopy(media)
        : null;
    final onKeepOffline0 = canDownload
        ? onKeepOffline != null
            ? onKeepOffline()
            : () async =>
                ref.read(serverProvider.notifier).onKeepMediaOffline(media)
        : null;

    final onUpload0 = onUpload != null ? onUpload() : null;
    final onDeleteServerCopy0 =
        onDeleteServerCopy != null ? onDeleteServerCopy() : null;

    return ContextMenuItems(
      name: media.name,
      assetPath: media.serverUID == null
          ? 'assets/icon/not_on_server.png'
          : 'assets/icon/cloud_on_lan_128px_color.png',
      onEdit:
          CLMenuItem(title: 'Edit', icon: clIcons.imageEdit, onTap: onEdit0),
      onMove:
          CLMenuItem(title: 'Move', icon: clIcons.imageMove, onTap: onMove0),
      onShare:
          CLMenuItem(title: 'Share', icon: clIcons.imageShare, onTap: onShare0),
      onPin: CLMenuItem(
        title: media.pin != null ? 'Remove Pin' : 'Pin',
        icon: media.pin != null ? clIcons.unPin : clIcons.pin,
        onTap: onPin0,
      ),
      onDelete: CLMenuItem(
        title: 'Delete',
        icon: clIcons.imageDelete,
        onTap: onDelete0,
      ),
      onDeleteLocalCopy: CLMenuItem(
        title: 'Remove downloads',
        icon: Icons.download_done_sharp,
        onTap: onDeleteLocalCopy0,
      ),
      onKeepOffline: CLMenuItem(
        title: 'Download',
        icon: Icons.download_sharp,
        onTap: onKeepOffline0,
      ),
      onUpload:
          CLMenuItem(title: 'Upload', icon: Icons.upload, onTap: onUpload0),
      onDeleteServerCopy: CLMenuItem(
        title: 'Permanently Delete',
        icon: Icons.remove,
        onTap: onDeleteServerCopy0,
      ),
      infoMap: media.toMapForDisplay(),
    );
  }
  final String name;
  final String assetPath;
  final CLMenuItem onEdit;
  final CLMenuItem onMove;
  final CLMenuItem onShare;
  final CLMenuItem onPin;
  final CLMenuItem onDelete;
  final CLMenuItem onDeleteLocalCopy;
  final CLMenuItem onKeepOffline;
  final CLMenuItem onUpload;
  final CLMenuItem onDeleteServerCopy;
  final Map<String, dynamic> infoMap;
}
