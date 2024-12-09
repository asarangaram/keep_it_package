import 'package:colan_services/colan_services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MediaEditorPage extends ConsumerWidget {
  const MediaEditorPage({
    required this.mediaId,
    required this.canDuplicateMedia,
    super.key,
  });
  final int? mediaId;
  final bool canDuplicateMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaId == null) {
      return BasicPageService.message(message: 'No Media Provided');
    }

    return MediaEditService(
      mediaId: mediaId,
      canDuplicateMedia: canDuplicateMedia,
      onDone: ({media}) async {
        context.pop(media);
      },
    );
  }
}
