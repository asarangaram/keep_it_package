import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../store_manager.dart';
import '../wrap_standard_quick_menu.dart';

class MediaAsFile extends ConsumerWidget {
  const MediaAsFile({
    required this.media,
    required this.quickMenuScopeKey,
    required this.onTap,
    required this.getPreview,
    super.key,
  });
  final CLMedia media;
  final Future<bool?> Function()? onTap;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final Widget Function(CLMedia media) getPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StoreManager(
      builder: ({required storeAction}) {
        return WrapStandardQuickMenu(
          quickMenuScopeKey: quickMenuScopeKey,
          onMove: () =>
              storeAction.openWizard([media], UniversalMediaSource.move),
          onDelete: () async {
            return ConfirmAction.deleteMedia(
              context,
              media: media,
              getPreview: getPreview,
              onConfirm: () => storeAction.delete([media], confirmed: true),
            );
          },
          onShare: () {
            final box = context.findRenderObject() as RenderBox?;
            return ShareManager.onShareFiles(
              [media.path],
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
            );
          },
          onEdit: () => storeAction.openEditor([media]),
          onTap: onTap,
          child: getPreview(media),
        );
      },
    );
  }
}
