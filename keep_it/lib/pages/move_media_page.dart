import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/widgets/empty_state.dart';
import 'package:store/store.dart';

import '../modules/shared_media/incoming_media_handler.dart';

class MoveMediaPage extends ConsumerWidget {
  const MoveMediaPage({
    required this.idsToMove,
    super.key,
    this.unhide = false,
  });

  final List<int> idsToMove;
  final bool unhide;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (idsToMove.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          await CLPopScreen.onPop(context);
        }
      });
      return FullscreenLayout(
        child: CLPopScreen.onSwipe(
          child: const EmptyState(
            message: 'Nothing to Move. You may be redirected',
          ),
        ),
      );
    }
    return FullscreenLayout(
      child: CLPopScreen.onSwipe(
        child: GetMediaMultiple(
          idList: idsToMove,
          buildOnData: (media) {
            final List<CLMedia> media2Move;
            if (unhide) {
              media2Move = media
                  .where(
                    (m) => idsToMove.contains(m.id),
                  )
                  .map((e) => e.copyWith(isHidden: false))
                  .toList();
            } else {
              media2Move = media
                  .where(
                    (m) => idsToMove.contains(m.id),
                  )
                  .toList();
            }
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
      ),
    );
  }
}
