import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/empty_state.dart';

import 'package:store/store.dart';

import '../modules/universal_media_handler/universal_media_handler.dart';

class StaleMediaPage extends ConsumerWidget {
  const StaleMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'Unclassified Media';
    const parentIdentifier = 'Unclassified Media';
    return FullscreenLayout(
      child: GetStaleMedia(
        buildOnData: (media) {
          if (media.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              CLPopScreen.onPop(context);
            });
          }
          return CLPopScreen.onSwipe(
            child: UniversalMediaHandler(
              label: label,
              parentIdentifier: parentIdentifier,
              media: media,
              emptyState: const EmptyState(),
            ),
          );
        },
      ),
    );
  }
}
