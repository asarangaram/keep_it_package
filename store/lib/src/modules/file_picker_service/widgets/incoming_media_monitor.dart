import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../media_wizard_service/models/cl_shared_media.dart';
import '../../media_wizard_service/providers/incoming_media.dart';

class IncomingMediaMonitor extends ConsumerWidget {
  const IncomingMediaMonitor({
    required this.child,
    required this.onMedia,
    super.key,
  });
  final Widget child;
  final Widget Function(
    BuildContext context, {
    required CLSharedMedia incomingMedia,
    required void Function({required bool result}) onDiscard,
  }) onMedia;

  static void pushMedia(WidgetRef ref, CLSharedMedia sharedMedia) {
    ref.read(incomingMediaStreamProvider.notifier).push(sharedMedia);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingMedia = ref.watch(incomingMediaStreamProvider);
    if (incomingMedia.isEmpty) {
      return child;
    }
    return onMedia(
      context,
      incomingMedia: incomingMedia[0],
      onDiscard: ({required bool result}) {
        ref.read(incomingMediaStreamProvider.notifier).pop();
      },
    );
  }
}
