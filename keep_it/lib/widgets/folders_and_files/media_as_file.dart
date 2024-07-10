import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/store_manager.dart';
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
    return MediaHandlerWidget(
      builder: ({required action}) {
        return WrapStandardQuickMenu(
          quickMenuScopeKey: quickMenuScopeKey,
          onMove: () => action.move([media]),
          onDelete: () => action.delete([media]),
          onShare: () => action.share([media]),
          onEdit: () => action.edit([media]),
          onTap: onTap,
          child: getPreview(media),
        );
      },
    );
  }
}
