import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../modules/shared_media/incoming_media_handler.dart';

class MoveMediaPage extends ConsumerWidget {
  const MoveMediaPage({
    required this.idsToMove,
    super.key,
  });

  final List<int> idsToMove;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      child: GetMediaMultiple(
        idList: idsToMove,
        buildOnData: (media) {
          final media2Move = media
              .where(
                (m) => idsToMove.contains(m.id),
              )
              .toList();
          return IncomingMediaHandler(
            incomingMedia: CLSharedMedia(entries: media2Move),
            onDiscard: ({required bool result}) {
              if (context.canPop()) {
                context.pop(result);
              }
            },
            moving: true,
          );
        },
      ),
    );
  }
}
