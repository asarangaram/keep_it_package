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
    return InkWell(
      onTap: () => sendMedia(capturedMedia),
      child: capturedMedia.isEmpty
          ? Container()
          : CapturedMediaDecorator(
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
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          8,
        ),
        child: child,
      ),
    );
  }
}
