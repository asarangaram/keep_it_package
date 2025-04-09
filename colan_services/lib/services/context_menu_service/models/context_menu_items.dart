import 'package:colan_widgets/colan_widgets.dart';
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
    required StoreEntity collection,
    required bool hasOnlineService,
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
              await updated.dbSave();
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
            final confirmed = await DialogService.deleteEntity(
                  context,
                  entity: collection.entity,
                ) ??
                false;

            if (context.mounted && confirmed) {
              await collection.delete();
              return true;
            }
            return false;
          };

    final ac = ActionControl.onGetCollectionActionControl(
      collection,
      hasOnlineService,
      onGetChildren: onGetChildren,
    );
    return CLContextMenu.template(
      name: collection.entity.label!,
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: ac.onEdit(onEdit0),
      onEditInfo: ac.onEdit(onEditInfo0),
      onMove: ac.onMove(onMove0),
      onShare: ac.onShare(onShare0),
      onPin: ac.onPin(onPin0),
      onDelete: ac.onDelete(onDelete0),
      infoMap: collection.entity.toMapForDisplay(),
      isPinned: false,
    );
  }
  factory CLContextMenu.ofMedia(
    BuildContext context,
    WidgetRef ref, {
    required StoreEntity media,
    required StoreEntity parentCollection,
    required bool hasOnlineService,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onDelete,
  }) {
    Future<bool> onEdit0() async {
      await PageManager.of(context).openEditor(media);
      return true;
    }

    Future<bool> onEditInfo0() async {
      final updated = await MediaMetadataEditor.openSheet(
        context,
        ref,
        media: media,
      );
      if (updated != null && context.mounted) {
        await updated.dbSave();
        return true;
      }

      return false;
    }

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

    final onShare0 =
        onShare != null ? onShare() : () => share(context, [media]);
    final onDelete0 = onDelete != null
        ? onDelete()
        : () async {
            final confirmed = await DialogService.deleteEntity(
                  context,
                  entity: media.entity,
                ) ??
                false;
            if (!confirmed) return confirmed;
            if (confirmed && context.mounted) {
              await media.delete();
            }
            return false;
          };

    Future<bool> onPin0() async {
      await media.onPin();
      return true;
    }

    final ac = ActionControl.onGetMediaActionControl(
      media.entity,
      parentCollection.entity,
      hasOnlineService,
    );
    return CLContextMenu.template(
      name: media.entity.label ?? 'Unnamed',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: ac.onEdit(onEdit0),
      onEditInfo: ac.onEdit(onEditInfo0),
      onMove: ac.onMove(onMove0),
      onShare: ac.onShare(onShare0),
      onPin: ac.onPin(onPin0),
      onDelete: ac.onDelete(onDelete0),
      infoMap: media.entity.toMapForDisplay(),
      isPinned: media.entity.pin != null,
    );
  }
  factory CLContextMenu.ofMultipleMedia(
    BuildContext context,
    WidgetRef ref, {
    required List<StoreEntity> items,
    // ignore: avoid_unused_constructor_parameters For now, not required
    required bool hasOnlineService,
    ValueGetter<Future<bool?> Function()?>? onEdit,
    ValueGetter<Future<bool?> Function()?>? onEditInfo,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onPin,
    ValueGetter<Future<bool?> Function()?>? onDelete,
  }) {
    final onEdit0 = onEdit?.call();
    final onEditInfo0 = onEditInfo?.call();
    Future<bool?> onMove0() => MediaWizardService.openWizard(
          context,
          ref,
          CLSharedMedia(
            entries: items,
            type: UniversalMediaSource.move,
          ),
        );
    Future<bool?> onShare0() => share(context, items);
    Future<bool> onPin0() async {
      for (final item in items) {
        await item.onPin();
      }
      return true;
    }

    Future<bool> onDelete0() async {
      final confirmed = await DialogService.deleteMultipleEntities(
            context,
            media: items.map((e) => e.entity).toList(),
          ) ??
          false;
      if (!confirmed) return confirmed;
      if (context.mounted) {
        for (final item in items) {
          await item.delete();
        }
        return true;
      }
      return false;
    }

    return CLContextMenu.template(
      name: 'Multiple Media',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: onEdit != null ? onEdit() : onEdit0,
      onEditInfo: onEditInfo != null ? onEditInfo() : onEditInfo0,
      onMove: onMove != null ? onMove() : onMove0,
      onShare: onShare != null ? onShare() : onShare0,
      onPin: onPin != null ? onPin() : onPin0,
      onDelete: onDelete != null ? onDelete() : onDelete0,
      infoMap: const {},
      isPinned: items.any((media) => media.entity.pin != null),
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
    CLStore theStore,
  ) {
    // FIXME
    return switch (entities) {
      final List<ViewerEntityMixin> e when e.every((e) => e is StoreEntity) =>
        () {
          return CLContextMenu.ofMultipleMedia(
            context,
            ref,
            items: e.map((e) => e as StoreEntity).toList(),
            hasOnlineService: true,
          );
        }(),
      final List<ViewerEntityMixin> e when e.every((e) => e is StoreEntity) =>
        () {
          return CLContextMenu.empty();
        }(),
      _ => throw UnimplementedError('Mix of items not supported yet')
    };
  }

  static Future<bool?> share(
    BuildContext context,
    List<StoreEntity> media,
  ) {
    throw UnimplementedError();
    /* final files = media.where((e)=>e.isCollection ==false)
        .map(directories.getMediaAbsolutePath)
        .where((e) => File(e).existsSync());
    final box = context.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      context,
      files.toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    ); */
  }
}

typedef DraggableMenuBuilderType = Widget Function(
  BuildContext, {
  required GlobalKey<State<StatefulWidget>> parentKey,
});
