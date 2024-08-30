import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/captured_media.dart';

class PreviewCapturedMedia extends ConsumerWidget {
  const PreviewCapturedMedia({
    required this.sendMedia,
    super.key,
  });
  final Future<void> Function(List<CLMedia>) sendMedia;

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
              child: MediaViewService.preview(capturedMedia.last),
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
