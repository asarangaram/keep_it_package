import 'dart:io';

import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:store/store.dart';

import '../../basic_page_service/widgets/dialogs.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../gallery_view_service/widgets/collection_editor.dart';
import '../../gallery_view_service/widgets/media_editor.dart';
import '../../media_wizard_service/media_wizard_service.dart';

@immutable
class EntityContextMenu extends CLContextMenu {
  const EntityContextMenu({
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
  factory EntityContextMenu.empty() {
    return EntityContextMenu.template(
      name: 'No Context Menu',
      logoImageAsset: '',
      infoMap: const {},
      isPinned: false,
    );
  }
  factory EntityContextMenu.template({
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
    return EntityContextMenu(
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
  factory EntityContextMenu.ofCollection(
    BuildContext context,
    WidgetRef ref, {
    required StoreEntity collection,
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
                  entity: collection,
                ) ??
                false;

            if (context.mounted && confirmed) {
              await collection.delete();
              return true;
            }
            return false;
          };

    final ac = onGetCollectionActionControl(
      collection,
      onGetChildren: onGetChildren,
    );
    return EntityContextMenu.template(
      name: collection.data.label!,
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: ac.onEdit(onEdit0),
      onEditInfo: ac.onEdit(onEditInfo0),
      onMove: ac.onMove(onMove0),
      onShare: ac.onShare(onShare0),
      onPin: ac.onPin(onPin0),
      onDelete: ac.onDelete(onDelete0),
      infoMap: collection.data.toMapForDisplay(),
      isPinned: false,
    );
  }
  factory EntityContextMenu.ofMedia(
    BuildContext context,
    WidgetRef ref, {
    required StoreEntity media,
    required StoreEntity parentCollection,
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
                  entity: media,
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

    final ac = onGetMediaActionControl(
      media,
      parentCollection,
    );
    return EntityContextMenu.template(
      name: media.data.label ?? 'Unnamed',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: ac.onEdit(onEdit0),
      onEditInfo: ac.onEdit(onEditInfo0),
      onMove: ac.onMove(onMove0),
      onShare: ac.onShare(onShare0),
      onPin: ac.onPin(onPin0),
      onDelete: ac.onDelete(onDelete0),
      infoMap: media.data.toMapForDisplay(),
      isPinned: media.data.pin != null,
    );
  }
  factory EntityContextMenu.ofMultipleMedia(
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
            media: items,
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

    return EntityContextMenu.template(
      name: 'Multiple Media',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onEdit: onEdit != null ? onEdit() : onEdit0,
      onEditInfo: onEditInfo != null ? onEditInfo() : onEditInfo0,
      onMove: onMove != null ? onMove() : onMove0,
      onShare: onShare != null ? onShare() : onShare0,
      onPin: onPin != null ? onPin() : onPin0,
      onDelete: onDelete != null ? onDelete() : onDelete0,
      infoMap: const {},
      isPinned: items.any((media) => media.data.pin != null),
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

  @override
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

  static EntityContextMenu entitiesContextMenuBuilder(
    BuildContext context,
    WidgetRef ref,
    List<ViewerEntityMixin> entities,
  ) {
    // FIXME
    return switch (entities) {
      final List<ViewerEntityMixin> e
          when e.every(
            (e) => e is StoreEntity && e.data.isCollection == false,
          ) =>
        () {
          return EntityContextMenu.ofMultipleMedia(
            context,
            ref,
            items: e.map((e) => e as StoreEntity).toList(),
            hasOnlineService: true,
          );
        }(),
      final List<ViewerEntityMixin> e
          when e.every(
            (e) => e is StoreEntity && e.data.isCollection == true,
          ) =>
        () {
          return EntityContextMenu.empty();
        }(),
      _ => throw UnimplementedError('Mix of items not supported yet')
    };
  }

  static Future<bool?> share(
    BuildContext context,
    List<StoreEntity> media,
  ) {
    final files = media
        .where((e) => e.mediaUri != null)
        .map((e) => e.mediaUri!.toFilePath())
        .where((e) => File(e).existsSync());

    final box = context.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      context,
      files.toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  static ActionControl onGetCollectionActionControl(
    StoreEntity collection, {
    List<ViewerEntityMixin>? Function(ViewerEntityMixin entity)? onGetChildren,
  }) {
    return const ActionControl(
      allowEdit: true,
      allowDelete: true,
      allowDeleteLocalCopy: true,
    );
  }

  static ActionControl onGetMediaActionControl(
    StoreEntity media,
    StoreEntity parentCollection,
  ) {
    final editSupported = switch (media.data.mediaType) {
      CLMediaType.text => false,
      CLMediaType.image => true,
      CLMediaType.video => ColanPlatformSupport.isMobilePlatform,
      CLMediaType.uri => false,
      CLMediaType.audio => false,
      CLMediaType.file => false,
      CLMediaType.unknown => false,
    };

    return ActionControl(
      allowEdit: editSupported,
      allowDelete: true,
      allowMove: true,
      allowShare: true,
      allowPin: ColanPlatformSupport.isMobilePlatform,
      allowDuplicateMedia: true,
    );
  }
}

typedef DraggableMenuBuilderType = Widget Function(
  BuildContext, {
  required GlobalKey<State<StatefulWidget>> parentKey,
});
