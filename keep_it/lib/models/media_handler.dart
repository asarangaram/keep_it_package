import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store/store.dart';

import 'album_manager_helper.dart';

class MediaHandler {
  MediaHandler({
    required CLMedia media,
    required this.dbManager,
  }) : media = [media];

  MediaHandler.multiple({
    required this.media,
    required this.dbManager,
  });
  final List<CLMedia> media;
  final DBManager dbManager;

  Future<bool> move(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }
    if (media.length == 1) {
      unawaited(
        context.push(
          '/move?ids=${media[0].id}',
        ),
      );
      return true;
    } else {
      final result = await context.push<bool>(
        '/move?ids=${media.map((e) => e.id).join(',')}',
      );

      return result ?? false;
    }
  }

  Future<bool> delete(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }
    if (media.length == 1) {
      return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CLConfirmAction(
                title: 'Confirm delete',
                message: 'Are you sure you want to delete '
                    'this ${media[0].type.name}?',
                child: PreviewService(media: media[0]),
                onConfirm: ({required confirmed}) async {
                  await dbManager.deleteMedia(
                    media[0],
                    onDeleteFile: (f) async => f.deleteIfExists(),
                    onRemovePin: (id) async =>
                        AlbumManagerHelper().removeMedia(context, ref, id),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop(confirmed);
                  }
                },
              );
            },
          ) ??
          false;
    } else {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CLConfirmAction(
                title: 'Confirm delete',
                message: 'Are you sure you want to delete '
                    '${media.length} items?',
                child: null,
                onConfirm: ({required confirmed}) =>
                    Navigator.of(context).pop(confirmed),
              );
            },
          ) ??
          false;
      if (confirmed) {
        await dbManager.deleteMediaMultiple(
          media,
          onDeleteFile: (f) async => f.deleteIfExists(),
          onRemovePinMultiple: (id) async =>
              AlbumManagerHelper().removeMultipleMedia(context, ref, id),
        );
      }
      return true;
    }
  }

  Future<bool> share(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }

    final box = context.findRenderObject() as RenderBox?;
    final files = media.map((e) => XFile(e.path)).toList();
    final shareResult = await Share.shareXFiles(
      files,
      // text: 'Share from KeepIT',
      subject: 'Exporting media from KeepIt',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
    return switch (shareResult.status) {
      ShareResultStatus.dismissed => false,
      ShareResultStatus.unavailable => false,
      ShareResultStatus.success => true,
    };
  }

  Future<bool> edit(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }
    if (media.length == 1) {
      if (media[0].pin != null) {
        await ref.read(notificationMessageProvider.notifier).push(
              "Unpin to edit.\n Pinned items can't be edited",
            );
        return true;
      } else {
        unawaited(
          context.push(
            '/mediaEditor?id=${media[0].id}',
          ),
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> togglePin(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }
    if (media.length == 1) {
      await dbManager.togglePin(
        media[0],
        onPin: AlbumManagerHelper().albumManager.addMedia,
        onRemovePin: (id) async =>
            AlbumManagerHelper().removeMedia(context, ref, id),
      );
      return true;
    } else {
      await dbManager.pinMediaMultiple(
        media,
        onPin: AlbumManagerHelper().albumManager.addMedia,
        onRemovePin: (id) async =>
            AlbumManagerHelper().removeMedia(context, ref, id),
      );
      return true;
    }
  }
}
