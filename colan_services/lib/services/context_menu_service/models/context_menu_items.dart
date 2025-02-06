import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:content_store/extensions/ext_cldirectories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

import '../../../internal/draggable_menu/widgets/actions_draggable_menu.dart';
import '../../basic_page_service/widgets/dialogs.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../gallery_view_service/widgets/collection_editor.dart';
import '../../media_wizard_service/media_wizard_service.dart';

@immutable
class CLContextMenu {
  const CLContextMenu({
    required this.name,
    required this.logoImageAsset,
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
  factory CLContextMenu.empty() {
    return CLContextMenu.template(
      name: 'No Context Menu',
      logoImageAsset: '',
      infoMap: const {},
      isPinned: false,
    );
  }
  factory CLContextMenu.template({
    required String name,
    required String logoImageAsset,
    required Map<String, dynamic> infoMap,
    required bool isPinned,
    Future<bool?> Function()? onEdit,
    Future<bool?> Function()? onMove,
    Future<bool?> Function()? onShare,
    Future<bool?> Function()? onPin,
    Future<bool?> Function()? onDelete,
    Future<bool?> Function()? onDeleteLocalCopy,
    Future<bool?> Function()? onKeepOffline,
    Future<bool?> Function()? onUpload,
    Future<bool?> Function()? onDeleteServerCopy,
  }) {
    return CLContextMenu(
      name: name,
      logoImageAsset: logoImageAsset,
      onEdit: CLMenuItem(
        title: 'Edit',
        icon: clIcons.imageEdit,
        onTap: onEdit,
      ),
      onMove: CLMenuItem(
        title: 'Move',
        icon: clIcons.imageMove,
        onTap: onMove,
      ),
      onShare: CLMenuItem(
        title: 'Share',
        icon: clIcons.imageShare,
        onTap: onShare,
      ),
      onPin: CLMenuItem(
        title: isPinned ? 'Remove Pin' : 'Pin',
        icon: isPinned ? clIcons.pin : clIcons.unPin,
        onTap: onPin,
      ),
      onDelete: CLMenuItem(
        title: 'Move to Bin',
        icon: clIcons.imageDelete,
        onTap: onDelete,
        isDestructive: true,
        tooltip: 'Moves to Recycle bin. Can recover as per Recycle Policy',
      ),
      onDeleteLocalCopy: CLMenuItem(
        title: 'Remove downloads',
        icon: Icons.download_done_sharp,
        onTap: onDeleteLocalCopy,
      ),
      onKeepOffline: CLMenuItem(
        title: 'Download',
        icon: Icons.download_sharp,
        onTap: onKeepOffline,
      ),
      onUpload:
          CLMenuItem(title: 'Upload', icon: Icons.upload, onTap: onUpload),
      onDeleteServerCopy: CLMenuItem(
        title: 'Remove From Server',
        icon: Icons.remove,
        onTap: onDeleteServerCopy,
        isDestructive: true,
        tooltip:
            'Delete from Server. Local copy is retained. Use if this is accidentally uploaded',
      ),
      infoMap: infoMap,
    );
  }
  factory CLContextMenu.ofCollection(
    BuildContext context,
    WidgetRef ref, {
    required Collection collection,
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
    List<CLEntity>? Function(CLEntity entity)? onGetChildren,
  }) {
    /// Basic Actions
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
    final onPin0 = onPin?.call();

    // Destructive Actions
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
              final theStore = await serverNotifier.storeUpdater;

              await theStore.collectionUpdater
                  .upsert(collection.copyWith(haveItOffline: false));
              final media = await theStore.store.reader
                  .getMediaByCollectionId(collection.id!);
              for (final m in media) {
                await theStore.mediaUpdater
                    .deleteLocalCopy(m, haveItOffline: () => null);
              }
              serverNotifier.instantSync();
              theStore.store.reloadStore();
            }
            return true;
          };
    // Online Actions
    final onKeepOffline0 = onKeepOffline != null
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
          };
    final onUpload0 = onUpload != null
        ? onUpload()
        : () async {
            await theStore.collectionUpdater.upsert(
              collection.copyWith(serverUID: () => -1, isEdited: true),
            );
            ref.read(serverProvider.notifier).instantSync();

            return true;
          };
    final onDeleteServerCopy0 = onDeleteServerCopy?.call();
    final ac = ActionControl.onGetCollectionActionControl(
      collection,
      hasOnlineService,
      onGetChildren: onGetChildren,
    );
    return CLContextMenu.template(
      name: collection.label,
      logoImageAsset: collection.serverUID == null
          ? 'assets/icon/not_on_server.png'
          : 'assets/icon/cloud_on_lan_128px_color.png',
      onEdit: ac.onEdit(onEdit0),
      onMove: ac.onMove(onMove0),
      onShare: ac.onShare(onShare0),
      onPin: ac.onPin(onPin0),
      onKeepOffline: ac.onKeepOffline(onKeepOffline0),
      onUpload: ac.onUpload(onUpload0),
      onDelete: ac.onDelete(onDelete0),
      onDeleteLocalCopy: ac.onDeleteLocalCopy(onDeleteLocalCopy0),
      onDeleteServerCopy: ac.onDeleteServerCopy(onDeleteServerCopy0),
      infoMap: collection.toMapForDisplay(),
      isPinned: false,
    );
  }
  factory CLContextMenu.ofMedia(
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
    final onMove0 = onMove != null
        ? onMove()
        : () => MediaWizardService.openWizard(
              context,
              ref,
              CLSharedMedia(
                entries: [media],
                type: UniversalMediaSource.move,
              ),
            );

    final onEdit0 = onEdit != null
        ? onEdit()
        : () async {
            await PageManager.of(context).openEditor(media);
            return true;
          };

    final onShare0 = onShare != null
        ? onShare()
        : () => theStore.mediaUpdater.share(context, [media]);
    final onDelete0 = onDelete != null
        ? onDelete()
        : () async {
            final confirmed = await DialogService.deleteMedia(
                  context,
                  media: media,
                ) ??
                false;
            if (!confirmed) return confirmed;
            if (context.mounted) {
              return theStore.mediaUpdater.delete(media.id!);
            }
            return null;
          };

    final onPin0 = onPin != null
        ? onPin()
        : () async => theStore.mediaUpdater.pinToggleMultiple(
              {media.id},
              onGetPath: (media) {
                if (media.isMediaLocallyAvailable) {
                  return theStore.directories.getMediaAbsolutePath(media);
                }

                return null;
              },
            );

    final onDeleteLocalCopy0 = onDeleteLocalCopy != null
        ? onDeleteLocalCopy()
        : () async =>
            ref.read(serverProvider.notifier).onDeleteMediaLocalCopy(media);
    final onKeepOffline0 = onKeepOffline != null
        ? onKeepOffline()
        : () async =>
            ref.read(serverProvider.notifier).onKeepMediaOffline(media);

    final onUpload0 = onUpload != null ? onUpload() : null;
    final onDeleteServerCopy0 =
        onDeleteServerCopy != null ? onDeleteServerCopy() : null;

    final ac = ActionControl.onGetMediaActionControl(
      media,
      parentCollection,
      hasOnlineService,
    );
    return CLContextMenu.template(
      name: media.name,
      logoImageAsset: media.serverUID == null
          ? 'assets/icon/not_on_server.png'
          : 'assets/icon/cloud_on_lan_128px_color.png',
      onEdit: ac.onEdit(onEdit0),
      onMove: ac.onMove(onMove0),
      onShare: ac.onShare(onShare0),
      onPin: ac.onPin(onPin0),
      onDelete: ac.onDelete(onDelete0),
      onDeleteLocalCopy: ac.onDeleteLocalCopy(onDeleteLocalCopy0),
      onKeepOffline: ac.onKeepOffline(onKeepOffline0),
      onUpload: ac.onUpload(onUpload0),
      onDeleteServerCopy: ac.onDeleteServerCopy(onDeleteServerCopy0),
      infoMap: media.toMapForDisplay(),
      isPinned: media.pin != null,
    );
  }
  factory CLContextMenu.ofMultipleMedia(
    BuildContext context,
    WidgetRef ref, {
    required List<CLMedia> items,
    // ignore: avoid_unused_constructor_parameters For now, not required
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
    final onEdit0 = onEdit != null ? onEdit() : null;
    final onMove0 = onMove != null
        ? onMove()
        : () => MediaWizardService.openWizard(
              context,
              ref,
              CLSharedMedia(
                entries: items,
                type: UniversalMediaSource.move,
              ),
            );
    final onShare0 = onShare != null
        ? onShare()
        : () => theStore.mediaUpdater.share(context, items);
    final onPin0 = onPin != null
        ? onPin()
        : () => theStore.mediaUpdater.pinToggleMultiple(
              items.map((e) => e.id).toSet(),
              onGetPath: (media) {
                throw UnimplementedError(
                  'onGetPath not yet implemented',
                );
              },
            );
    final onDelete0 = onDelete != null
        ? onDelete()
        : () async {
            final confirmed = await DialogService.deleteMediaMultiple(
                  context,
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
          };
    final onDeleteLocalCopy0 =
        onDeleteLocalCopy != null ? onDeleteLocalCopy() : null;
    final onKeepOffline0 = onKeepOffline != null ? onKeepOffline() : null;
    final onUpload0 = onUpload != null ? onUpload() : null;
    final onDeleteServerCopy0 =
        onDeleteServerCopy != null ? onDeleteServerCopy() : null;

    return CLContextMenu.template(
      name: 'Multiple Media',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: onEdit0,
      onMove: onMove0,
      onShare: onShare0,
      onPin: onPin0,
      onDelete: onDelete0,
      onDeleteLocalCopy: onDeleteLocalCopy0,
      onKeepOffline: onKeepOffline0,
      onUpload: onUpload0,
      onDeleteServerCopy: onDeleteServerCopy0,
      infoMap: const {},
      isPinned: items.any((media) => media.pin != null),
    );
  }
  final String name;
  final String logoImageAsset;
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

  List<CLMenuItem> get actions => [
        onEdit,
        onMove,
        onShare,
        onPin,
        onDelete,
        onDeleteLocalCopy,
        onKeepOffline,
        onUpload,
        onDeleteServerCopy,
      ].where((e) => e.onTap != null).toList();

  List<CLMenuItem> get basicActions => [
        onEdit,
        onMove,
        onShare,
        onPin,
      ];

  List<CLMenuItem> get onlineActions => [
        onKeepOffline,
        onUpload,
      ];

  List<CLMenuItem> get destructiveActions => [
        onDelete,
        onDeleteLocalCopy,
        onDeleteServerCopy,
      ];

  DraggableMenuBuilderType? draggableMenuBuilder(
    BuildContext context,
    void Function() onDone,
  ) {
    if (actions.isNotEmpty) {
      return (context, {required parentKey}) {
        return ActionsDraggableMenu<CLEntity>(
          parentKey: parentKey,
          tagPrefix: 'Selection',
          menuItems: actions.insertOnDone(onDone),
        );
      };
    }

    return null;
  }

  static CLContextMenu entitiesContextMenuBuilder(
    BuildContext context,
    WidgetRef ref,
    List<CLEntity> entities,
    StoreUpdater theStore,
  ) {
    return switch (entities) {
      final List<CLEntity> e when e.every((e) => e is CLMedia) => () {
          return CLContextMenu.ofMultipleMedia(
            context,
            ref,
            items: e.map((e) => e as CLMedia).toList(),
            hasOnlineService: true,
            theStore: theStore,
          );
        }(),
      final List<CLEntity> e when e.every((e) => e is Collection) => () {
          return CLContextMenu.empty();
        }(),
      _ => throw UnimplementedError('Mix of items not supported yet')
    };
  }
}

typedef DraggableMenuBuilderType = Widget Function(
  BuildContext, {
  required GlobalKey<State<StatefulWidget>> parentKey,
});
