import 'dart:io';

import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../models/cl_shared_media.dart';
import '../../../models/platform_support.dart';
import '../../../models/universal_media_source.dart';
import '../../basic_page_service/widgets/dialogs.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../media_wizard_service/media_wizard_service.dart';
import '../widgets/collection_metadata_editor.dart';
import '../widgets/media_metadata_editor.dart';

@immutable
class EntityActions extends CLContextMenu {
  const EntityActions({
    required this.name,
    required this.logoImageAsset,
    required this.onCrop,
    required this.onEdit,
    required this.onMove,
    required this.onShare,
    required this.onPin,
    required this.onDelete,
    required this.infoMap,
  });

  factory EntityActions.entities(
    BuildContext context,
    WidgetRef ref,
    List<ViewerEntityMixin> entities,
  ) {
    return switch (entities) {
      final List<ViewerEntityMixin> e
          when e.every(
            (e) => e is StoreEntity && e.data.isCollection == false,
          ) =>
        () {
          return EntityActions.ofMultipleMedia(
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
          return EntityActions.empty();
        }(),
      _ => () {
          return EntityActions.empty();
        }()
    };
  }
  factory EntityActions.ofEntity(
    BuildContext context,
    WidgetRef ref,
    StoreEntity entity,
  ) {
    Future<bool> onEdit() async {
      if (context.mounted) {
        final updated = await (entity.isCollection
            ? CollectionMetadataEditor.openSheet(
                context,
                ref,
                collection: entity,
              )
            : MediaMetadataEditor.openSheet(
                context,
                ref,
                media: entity,
              ));
        if (updated != null && context.mounted) {
          await updated.dbSave();
        }
      }

      return true;
    }

    final cropSupported = switch (entity.data.mediaType) {
      CLMediaType.text => false,
      CLMediaType.image => true,
      CLMediaType.video => ColanPlatformSupport.isMobilePlatform,
      CLMediaType.uri => false,
      CLMediaType.audio => false,
      CLMediaType.file => false,
      CLMediaType.unknown => false,
      CLMediaType.collection => false,
    };

    Future<bool> onCrop() async {
      await PageManager.of(context).openEditor(entity);
      return true;
    }

    Future<bool?> onMove() => MediaWizardService.openWizard(
          context,
          ref,
          CLSharedMedia(
            entries: [entity],
            type: UniversalMediaSource.move,
          ),
        );
    Future<bool> onDelete() async {
      final confirmed = await DialogService.deleteEntity(
            context,
            entity: entity,
          ) ??
          false;

      if (confirmed && context.mounted) {
        await entity.delete();
        return true;
      }
      return false;
    }

    Future<bool?> onShare() => share(context, [entity]);

    Future<bool> onPin() async {
      await entity.onPin();
      return true;
    }

    return EntityActions.template(
      name: entity.data.label ?? 'Unnamed',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onCrop: cropSupported ? onCrop : null,
      onEdit: onEdit,
      onMove: onMove,
      onShare: entity.isCollection ? null : onShare,
      onPin: !entity.isCollection && !ColanPlatformSupport.isMobilePlatform
          ? onPin
          : null,
      onDelete: onDelete,
      infoMap: entity.data.toMapForDisplay(),
      isPinned: false,
    );
  }
  factory EntityActions.empty() {
    return EntityActions.template(
      name: 'No Context Menu',
      logoImageAsset: '',
      infoMap: const {},
      isPinned: false,
    );
  }
  factory EntityActions.template({
    required String name,
    required String logoImageAsset,
    required Map<String, dynamic> infoMap,
    required bool isPinned,
    Future<bool?> Function()? onCrop,
    Future<bool?> Function()? onEdit,
    Future<bool?> Function()? onMove,
    Future<bool?> Function()? onShare,
    Future<bool?> Function()? onPin,
    Future<bool?> Function()? onDelete,
  }) {
    return EntityActions(
      name: name,
      logoImageAsset: logoImageAsset,
      onCrop: CLMenuItem(
        title: 'Edit',
        icon: clIcons.imageEdit,
        onTap: onCrop,
      ),
      onEdit: CLMenuItem(
        title: 'Info',
        icon: LucideIcons.info,
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
      infoMap: infoMap,
    );
  }

  factory EntityActions.ofMultipleMedia(
    BuildContext context,
    WidgetRef ref, {
    required List<StoreEntity> items,
    // ignore: avoid_unused_constructor_parameters For now, not required
    required bool hasOnlineService,
    ValueGetter<Future<bool?> Function()?>? onCrop,
    ValueGetter<Future<bool?> Function()?>? onEdit,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onPin,
    ValueGetter<Future<bool?> Function()?>? onDelete,
  }) {
    final onEdit0 = onCrop?.call();
    final onEditInfo0 = onEdit?.call();
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

    return EntityActions.template(
      name: 'Multiple Media',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onCrop: onCrop != null ? onCrop() : onEdit0,
      onEdit: onEdit != null ? onEdit() : onEditInfo0,
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
  final CLMenuItem onCrop;
  final CLMenuItem onEdit;
  final CLMenuItem onMove;
  final CLMenuItem onShare;
  final CLMenuItem onPin;
  final CLMenuItem onDelete;

  final Map<String, dynamic> infoMap;

  @override
  List<CLMenuItem> get actions => [
        onCrop,
        onEdit,
        onMove,
        onShare,
        onPin,
        onDelete,
      ].where((e) => e.onTap != null).toList();

  List<CLMenuItem> get basicActions => [
        onCrop,
        onEdit,
        onMove,
        onShare,
        onPin,
      ];

  List<CLMenuItem> get destructiveActions => [
        onDelete,
      ];

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
}

typedef DraggableMenuBuilderType = Widget Function(
  BuildContext, {
  required GlobalKey<State<StatefulWidget>> parentKey,
});
