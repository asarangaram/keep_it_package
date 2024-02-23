import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/incoming_media.dart';

class IncomingMediaMonitor extends ConsumerWidget {
  const IncomingMediaMonitor({
    required this.child,
    required this.onMedia,
    super.key,
  });
  final Widget child;
  final Widget Function(
    BuildContext context, {
    required CLMediaList incomingMedia,
    required void Function() onDiscard,
  }) onMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingMedia = ref.watch(incomingMediaStreamProvider);
    if (incomingMedia.isEmpty) {
      return child;
    }
    return onMedia(
      context,
      incomingMedia: incomingMedia[0],
      onDiscard: () {
        ref.read(incomingMediaStreamProvider.notifier).pop();
      },
    );
  }
}
