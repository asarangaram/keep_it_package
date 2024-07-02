import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../models/media_handler.dart';
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
        final mediaHandler = MediaHandler(media: media, dbManager: dbManager);
        return WrapStandardQuickMenu(
          quickMenuScopeKey: quickMenuScopeKey,
          onMove: () => mediaHandler.onMove(context, ref),
          onDelete: () => mediaHandler.onDelete(context, ref),
          onShare: () => mediaHandler.onShare(context, ref),
          onEdit: () => mediaHandler.onEdit(context, ref),
          onTap: onTap,
          child: PreviewService(
            media: media,
            keepAspectRatio: false,
          ),
        );
      },
    );
  }
}
