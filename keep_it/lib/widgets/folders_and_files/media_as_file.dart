import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store/store.dart';

import '../wrap_standard_quick_menu.dart';

class MediaAsFile extends ConsumerWidget {
  const MediaAsFile({
    required this.media,
    required this.quickMenuScopeKey,
    required this.onTap,
    super.key,
  });
  final CLMedia media;
  final Future<bool?> Function()? onTap;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return WrapStandardQuickMenu(
          quickMenuScopeKey: quickMenuScopeKey,
          onMove: () async {
            unawaited(
              context.push(
                '/move?ids=${media.id}',
              ),
            );
            return true;
          },
          onDelete: () async =>
              await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return CLConfirmAction(
                    title: 'Confirm delete',
                    message: 'Are you sure you want to delete '
                        'this ${media.type.name}?',
                    child: CLMediaPreview(media: media),
                    onConfirm: ({required confirmed}) async {
                      await dbManager.deleteMedia(
                        media,
                        onDeleteFile: (f) async => f.deleteIfExists(),
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop(confirmed);
                      }
                    },
                  );
                },
              ) ??
              false,
          onTap: onTap,
          onShare: () async {
            final box = context.findRenderObject() as RenderBox?;
            final files = [XFile(media.path)];
            final shareResult = await Share.shareXFiles(
              files,
              // text: 'Share from KeepIT',
              subject: 'Find the media from KeepIt',
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
            );
            return switch (shareResult.status) {
              ShareResultStatus.dismissed => false,
              ShareResultStatus.unavailable => false,
              ShareResultStatus.success => true,
            };
          },
          onEdit: media.type != CLMediaType.video
              ? null
              : () async {
                  unawaited(
                    context.push(
                      '/mediaEditor?id=${media.id}',
                    ),
                  );
                  return true;
                },
          child: CLMediaPreview(
            media: media,
            keepAspectRatio: false,
          ),
        );
      },
    );
  }
}
