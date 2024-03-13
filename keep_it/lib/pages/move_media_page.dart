import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../modules/shared_media/incoming_media_handler.dart';

class MoveMediaPage extends ConsumerWidget {
  const MoveMediaPage({
    required this.idsToMove,
    required this.collectionId,
    super.key,
  });
  final int collectionId;
  final List<int> idsToMove;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMediaByCollectionId(
      collectionId: collectionId,
      buildOnData: (media) {
        final media2Move = media
            .where(
              (m) => idsToMove.contains(m.id),
            )
            .toList();
        return IncomingMediaHandler(
          incomingMedia: CLSharedMedia(entries: media2Move),
          onDiscard: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          moving: true,
        );
      },
    );
  }
}
