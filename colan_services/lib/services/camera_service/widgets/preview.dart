import 'package:cl_entity_viewers/cl_entity_viewers.dart' show MediaThumbnail;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:store/store.dart';

import '../../../providers/captured_media.dart';

class PreviewCapturedMedia extends ConsumerWidget {
  const PreviewCapturedMedia({
    required this.sendMedia,
    required this.parentIdentifier,
    super.key,
  });
  final String parentIdentifier;
  final Future<void> Function(List<StoreEntity>) sendMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);
    return capturedMedia.isEmpty
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              final capturedMediaCopy = [...capturedMedia];
              ref.read(capturedMediaProvider.notifier).clear();
              sendMedia(capturedMediaCopy);
            },
            child: CapturedMediaDecorator(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MediaThumbnail(
                      parentIdentifier: parentIdentifier,
                      media: capturedMedia.last,
                    ),
                  ),
                  Center(
                    child: ShadBadge.destructive(
                      child: Text(capturedMedia.length.toString()),
                    ),
                  ),
                ],
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
