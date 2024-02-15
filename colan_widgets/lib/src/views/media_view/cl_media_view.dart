import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cl_media.dart';
import '../../services/image_services/image_view.dart';
import '../../services/video_services/video_player.dart';

class CLMediaView extends ConsumerWidget {
  const CLMediaView({
    required this.media,
    super.key,
    this.isSelected = true,
    this.onSelect,
  });
  final CLMedia media;
  final void Function()? onSelect;
  final bool isSelected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (media.type.isFile && !File(media.path).existsSync()) {
      return const BrokenImage();
    }

    return Hero(
      tag: '/item/${media.collectionId}/${media.id}',
      child: switch (media.type) {
        CLMediaType.image => Center(child: Image.file(File(media.path))),
        CLMediaType.video => VideoPlayer(
            media: media,
            isSelected: isSelected,
            onSelect: onSelect,
          ),
        _ => throw UnimplementedError('Not yet implemented')
      },
    );
  }
}
