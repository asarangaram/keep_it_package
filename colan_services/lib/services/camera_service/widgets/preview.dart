import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/captured_media.dart';

class PreviewCapturedMedia extends ConsumerWidget {
  const PreviewCapturedMedia({
    required this.sendMedia,
    required this.getPreview,
    super.key,
  });
  final Future<void> Function(List<CLMedia>) sendMedia;
  final Widget Function(CLMedia media) getPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);
    return capturedMedia.isEmpty
        ? const SizedBox.shrink()
        : InkWell(
            onTap: () {
              final capturedMediaCopy = [...capturedMedia];
              ref.read(capturedMediaProvider.notifier).clear();
              sendMedia(capturedMediaCopy);
            },
            child: CapturedMediaDecorator(
              child: getPreview(capturedMedia.last),
            ),
          );
  }
}

class CapturedMediaDecorator extends StatelessWidget {
  const CapturedMediaDecorator({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}
