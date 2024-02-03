import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../widgets/from_store/from_store.dart';
import '../widgets/video_player.dart';

class ItemViewByID extends ConsumerWidget {
  const ItemViewByID({required this.id, required this.collectionId, super.key});
  final int collectionId;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadItems(
      collectionID: collectionId,
      buildOnData: (Items items) {
        final media = items.entries.where((e) => e.id == id).first;
        return ItemView(media: media);
      },
    );
  }
}

class ItemView extends ConsumerWidget {
  const ItemView({required this.media, super.key});
  final CLMedia media;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (media.type.isFile && !File(media.path).existsSync()) {
      throw Exception('File not found ${media.path}');
    }
    return Hero(
      tag: '/item/${media.collectionId}/${media.id}',
      child: File(media.path).existsSync()
          ? switch (media) {
              (final image) when image.type == CLMediaType.image => Image.file(
                  File(image.path),
                ),
              (final video) when video.type == CLMediaType.video =>
                VideoPlayerScreen(
                  path: video.path,
                ),
              _ => throw UnimplementedError(
                  'Not yet implemented',
                )
            }
          : const Text('Media not found'),
    );
  }
}
