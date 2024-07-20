import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../wrap_standard_quick_menu.dart';

class MediaAsFile extends ConsumerWidget {
  const MediaAsFile({
    required this.media,
    required this.quickMenuScopeKey,
    required this.onTap,
    required this.getPreview,
    required this.actionControl,
    super.key,
  });
  final CLMedia media;
  final Future<bool?> Function()? onTap;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final Widget Function(CLMedia media) getPreview;
  final ActionControl actionControl;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WrapStandardQuickMenu(
      quickMenuScopeKey: quickMenuScopeKey,
      onMove: () => TheStore.of(context)
          .openWizard(context, [media], UniversalMediaSource.move),
      onDelete: () async {
        return TheStore.of(context).deleteMediaMultiple(context, [media]);
      },
      onShare: () => TheStore.of(context).shareMediaMultiple(context, [media]),
      onEdit:
          (media.type == CLMediaType.video && !VideoEditServices.isSupported)
              ? null
              : () async {
                  final updatedMedia = await TheStore.of(context).openEditor(
                    context,
                    media,
                    canDuplicateMedia: actionControl.canDuplicateMedia,
                  );
                  return true;
                },
      onTap: onTap,
      child: getPreview(media),
    );
  }
}
