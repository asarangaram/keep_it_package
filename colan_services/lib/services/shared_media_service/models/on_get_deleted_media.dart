import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../preview_service/view/preview.dart';
import 'album_manager_helper.dart';

class OnGetDeletedMedia extends ConsumerWidget {
  const OnGetDeletedMedia({
    required this.buildOnData,
    super.key,
  });
  final Widget Function(
    List<CLMedia> items, {
    required Future<bool> Function(List<CLMedia> selectedMedia) onRestore,
    required Future<bool> Function(List<CLMedia> selectedMedia) onDelete,
  }) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return GetDeletedMedia(
          buildOnData: (media) {
            media.sort((a, b) {
              final aDate = a.originalDate ?? a.createdDate;
              final bDate = b.originalDate ?? b.createdDate;

              if (aDate != null && bDate != null) {
                return bDate.compareTo(aDate);
              }
              return 0;
            });
            return DeletedMediaHandler(
              dbManager: dbManager,
              media0: media,
              buildOnData: buildOnData,
            );
          },
        );
      },
    );
  }
}

class DeletedMediaHandler extends ConsumerStatefulWidget {
  const DeletedMediaHandler({
    required this.dbManager,
    required this.media0,
    required this.buildOnData,
    super.key,
  });
  final DBManager dbManager;
  final List<CLMedia> media0;
  final Widget Function(
    List<CLMedia> items, {
    required Future<bool> Function(List<CLMedia> selectedMedia) onRestore,
    required Future<bool> Function(List<CLMedia> selectedMedia) onDelete,
  }) buildOnData;

  @override
  ConsumerState<DeletedMediaHandler> createState() =>
      _DeletedMediaHandlerState();
}

class _DeletedMediaHandlerState extends ConsumerState<DeletedMediaHandler> {
  @override
  Widget build(BuildContext context) {
    return widget.buildOnData(
      widget.media0,
      onRestore: onRestore,
      onDelete: onDelete,
    );
  }

  Future<bool> onDelete(List<CLMedia> selectedMedia) async {
    if (selectedMedia.isEmpty) {
      return true;
    }
    if (selectedMedia.length == 1) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CLConfirmAction(
                title: 'Confirm delete',
                message: 'Are you sure you want to delete '
                    'this ${selectedMedia[0].type.name}?',
                child: PreviewService(media: selectedMedia[0]),
                onConfirm: ({required confirmed}) async {
                  if (context.mounted) {
                    Navigator.of(context).pop(confirmed);
                  }
                },
              );
            },
          ) ??
          false;
      if (confirmed) {
        await widget.dbManager.deleteMedia(
          selectedMedia[0],
          onDeleteFile: (f) async => f.deleteIfExists(),
          onRemovePin: (id) async =>
              AlbumManagerHelper().removeMedia(context, ref, id),
        );
        return true;
      }
      return false;
    } else {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CLConfirmAction(
                title: 'Confirm delete',
                message: 'Are you sure you want to delete '
                    '${selectedMedia.length} items?',
                child: null,
                onConfirm: ({required confirmed}) =>
                    Navigator.of(context).pop(confirmed),
              );
            },
          ) ??
          false;
      if (confirmed) {
        await widget.dbManager.deleteMediaMultiple(
          selectedMedia,
          onDeleteFile: (f) async => f.deleteIfExists(),
          onRemovePinMultiple: (id) async =>
              AlbumManagerHelper().removeMultipleMedia(context, ref, id),
        );
      }
      return confirmed;
    }
  }

  Future<bool> onRestore(List<CLMedia> selectedMedia) async {
    for (final item in selectedMedia) {
      if (item.id != null) {
        await widget.dbManager.upsertMedia(
          collectionId: item.collectionId!,
          media: item.copyWith(isDeleted: false),
          onPrepareMedia: (
            m, {
            required targetDir,
          }) async {
            final updated = (await m.moveFile(
              targetDir: targetDir,
            ))
                .getMetadata();
            return updated;
          },
        );
      }
    }
    return true;
  }
}
