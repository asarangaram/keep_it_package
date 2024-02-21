import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import 'wrap_standard_quick_menu.dart';

class MediaAsFile extends ConsumerWidget {
  const MediaAsFile({
    required this.media,
    required this.quickMenuScopeKey,
    super.key,
  });
  final CLMedia media;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WrapStandardQuickMenu(
      quickMenuScopeKey: quickMenuScopeKey,
      onEdit: () async {
        
        return true;
      },
      onDelete: () async {
        return true;
      },
      onTap: () async {
        unawaited(
          context.push('/item/${media.collectionId}/${media.id}'),
        );
        return true;
      },
      child: CLMediaPreview(
        media: media,
        keepAspectRatio: false,
      ),
    );
  }
}
