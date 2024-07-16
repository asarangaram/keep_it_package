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
      onMove: () =>
          TheStore.of(context).openWizard([media], UniversalMediaSource.move),
      onDelete: () async {
        return ConfirmAction.deleteMedia(
          context,
          media: media,
          getPreview: getPreview,
          onConfirm: () =>
              TheStore.of(context).delete([media], confirmed: true),
        );
      },
      onShare: () => TheStore.of(context).share([media]),
      onEdit:
          (media.type == CLMediaType.video && !VideoEditServices.isSupported)
              ? null
              : () => TheStore.of(context).openEditor(
                    [media],
                    canDuplicateMedia: actionControl.canDuplicateMedia,
                  ),
      onTap: onTap,
      child: getPreview(media),
    );
  }
}
