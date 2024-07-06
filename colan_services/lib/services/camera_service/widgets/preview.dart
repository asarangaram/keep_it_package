import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../preview_service/view/preview.dart';
import '../providers/captured_media.dart';

class PreviewCapturedMedia extends ConsumerWidget {
  const PreviewCapturedMedia({required this.sendMedia, super.key});
  final Future<void> Function(List<CLMedia>) sendMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);
    return capturedMedia.isEmpty
        ? const SizedBox.shrink()
        : InkWell(
            onTap: () => sendMedia(capturedMedia),
            child: CapturedMediaDecorator(
              child: PreviewService(
                media: capturedMedia.last,
                keepAspectRatio: false,
              ),
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
