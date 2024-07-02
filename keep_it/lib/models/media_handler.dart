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
    required this.media,
    required this.dbManager,
  });
  final CLMedia media;
  final DBManager dbManager;

  Future<bool> onMove(
    BuildContext context,
    WidgetRef ref,
  ) async {
    unawaited(
      context.push(
        '/move?ids=${media.id}',
      ),
    );
    return true;
  }

  Future<bool> onDelete(
    BuildContext context,
    WidgetRef ref,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return CLConfirmAction(
            title: 'Confirm delete',
            message: 'Are you sure you want to delete '
                'this ${media.type.name}?',
            child: PreviewService(media: media),
            onConfirm: ({required confirmed}) async {
              await dbManager.deleteMedia(
                media,
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

  Future<bool> onShare(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    final files = [XFile(media.path)];
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

  Future<bool> onEdit(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.pin != null) {
      await ref.read(notificationMessageProvider.notifier).push(
            "Unpin to edit.\n Pinned items can't be edited",
          );
      return true;
    } else {
      unawaited(
        context.push(
          '/mediaEditor?id=${media.id}',
        ),
      );
      return true;
    }
  }

  Future<bool> onPin(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await dbManager.togglePin(
      media,
      onPin: AlbumManagerHelper().albumManager.addMedia,
      onRemovePin: (id) async =>
          AlbumManagerHelper().removeMedia(context, ref, id),
    );
    return true;
  }
}
