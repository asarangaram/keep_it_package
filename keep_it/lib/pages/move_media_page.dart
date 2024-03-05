import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../modules/shared_media/incoming_media_handler.dart';

class MoveMediaPage extends ConsumerWidget {
  const MoveMediaPage({
    required this.id,
    required this.collectionId,
    super.key,
  });
  final int collectionId;
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMedia(
      id: id,
      buildOnData: (media) {
        return IncomingMediaHandler(
          incomingMedia: CLSharedMedia(entries: [media]),
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
