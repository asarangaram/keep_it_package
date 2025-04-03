import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:content_store/extensions/ext_cldirectories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:store/store.dart';

import '../../../internal/draggable_menu/widgets/actions_draggable_menu.dart';
import '../../basic_page_service/widgets/dialogs.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../gallery_view_service/widgets/collection_editor.dart';
import '../../gallery_view_service/widgets/media_editor.dart';
import '../../media_wizard_service/media_wizard_service.dart';

@immutable
class CLContextMenu {
  const CLContextMenu({
    required this.name,
    required this.logoImageAsset,
    required this.onEdit,
    required this.onEditInfo,
    required this.onMove,
    required this.onShare,
    required this.onPin,
    required this.onDelete,
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
    Future<bool?> Function()? onEditInfo,
    Future<bool?> Function()? onMove,
    Future<bool?> Function()? onShare,
    Future<bool?> Function()? onPin,
    Future<bool?> Function()? onDelete,
  }) {
    return CLContextMenu(
      name: name,
      logoImageAsset: logoImageAsset,
      onEdit: CLMenuItem(
        title: 'Edit',
        icon: clIcons.imageEdit,
        onTap: onEdit,
      ),
      onEditInfo: CLMenuItem(
        title: 'Info',
        icon: LucideIcons.info,
        onTap: onEditInfo,
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
      infoMap: infoMap,
    );
  }
  factory CLContextMenu.ofCollection(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia collection,
    required bool hasOnlineService,
    required StoreUpdater theStore,
    ValueGetter<Future<bool?> Function()?>? onEdit,
    ValueGetter<Future<bool?> Function()?>? onEditInfo,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onPin,
    ValueGetter<Future<bool?> Function()?>? onDelete,
    List<ViewerEntityMixin>? Function(ViewerEntityMixin entity)? onGetChildren,
  }) {
    /// Basic Actions
    final onEditInfo0 = onEditInfo != null
        ? onEditInfo()
        : () async {
            final updated = await CollectionEditor.openSheet(
              context,
              ref,
              collection: collection,
            );
            if (updated != null && context.mounted) {
              await theStore.collectionUpdater.update(updated, isEdited: true);
            }

            return true;
          };

    final onEdit0 = onEdit?.call();
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

    final ac = ActionControl.onGetCollectionActionControl(
      collection,
      hasOnlineService,
      onGetChildren: onGetChildren,
    );
    return CLContextMenu.template(
      name: collection.label!,
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: ac.onEdit(onEdit0),
      onEditInfo: ac.onEdit(onEditInfo0),
      onMove: ac.onMove(onMove0),
      onShare: ac.onShare(onShare0),
      onPin: ac.onPin(onPin0),
      onDelete: ac.onDelete(onDelete0),
      infoMap: collection.toMapForDisplay(),
      isPinned: false,
    );
  }
  factory CLContextMenu.ofMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia media,
    required CLMedia parentCollection,
    required bool hasOnlineService,
    required StoreUpdater theStore,
    ValueGetter<Future<bool?> Function()?>? onEdit,
    ValueGetter<Future<bool?> Function()?>? onEditInfo,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onPin,
    ValueGetter<Future<bool?> Function()?>? onDelete,
  }) {
    final onEdit0 = onEdit != null
        ? onEdit()
        : () async {
            await PageManager.of(context).openEditor(media);
            return true;
          };
    final onEditInfo0 = onEditInfo != null
        ? onEditInfo()
        : () async {
            final updated = await MediaMetadataEditor.openSheet(
              context,
              ref,
              media: media,
            );
            if (updated != null && context.mounted) {
              await theStore.mediaUpdater.update(updated, isEdited: true);
            }

            return true;
          };
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
                return theStore.directories.getMediaAbsolutePath(media);
              },
            );

    final ac = ActionControl.onGetMediaActionControl(
      media,
      parentCollection,
      hasOnlineService,
    );
    return CLContextMenu.template(
      name: media.label ?? 'Unnamed',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: ac.onEdit(onEdit0),
      onEditInfo: ac.onEdit(onEditInfo0),
      onMove: ac.onMove(onMove0),
      onShare: ac.onShare(onShare0),
      onPin: ac.onPin(onPin0),
      onDelete: ac.onDelete(onDelete0),
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
    ValueGetter<Future<bool?> Function()?>? onEditInfo,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onPin,
    ValueGetter<Future<bool?> Function()?>? onDelete,
  }) {
    final onEdit0 = onEdit?.call();
    final onEditInfo0 = onEditInfo?.call();
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

    return CLContextMenu.template(
      name: 'Multiple Media',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: onEdit0,
      onEditInfo: onEditInfo0,
      onMove: onMove0,
      onShare: onShare0,
      onPin: onPin0,
      onDelete: onDelete0,
      infoMap: const {},
      isPinned: items.any((media) => media.pin != null),
    );
  }
  final String name;
  final String logoImageAsset;
  final CLMenuItem onEdit;
  final CLMenuItem onEditInfo;
  final CLMenuItem onMove;
  final CLMenuItem onShare;
  final CLMenuItem onPin;
  final CLMenuItem onDelete;

  final Map<String, dynamic> infoMap;

  List<CLMenuItem> get actions => [
        onEdit,
        onEditInfo,
        onMove,
        onShare,
        onPin,
        onDelete,
      ].where((e) => e.onTap != null).toList();

  List<CLMenuItem> get basicActions => [
        onEdit,
        onEditInfo,
        onMove,
        onShare,
        onPin,
      ];

  List<CLMenuItem> get destructiveActions => [
        onDelete,
      ];

  DraggableMenuBuilderType? draggableMenuBuilder(
    BuildContext context,
    void Function() onDone,
  ) {
    if (actions.isNotEmpty) {
      return (context, {required parentKey}) {
        return ActionsDraggableMenu<ViewerEntityMixin>(
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
    List<ViewerEntityMixin> entities,
    StoreUpdater theStore,
  ) {
    // FIXME
    return switch (entities) {
      final List<ViewerEntityMixin> e when e.every((e) => e is CLMedia) => () {
          return CLContextMenu.ofMultipleMedia(
            context,
            ref,
            items: e.map((e) => e as CLMedia).toList(),
            hasOnlineService: true,
            theStore: theStore,
          );
        }(),
      final List<ViewerEntityMixin> e when e.every((e) => e is CLMedia) => () {
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
