import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../media_view_service/preview/media_preview.dart';

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
        : InkWell(
            onTap: () {
              final capturedMediaCopy = [...capturedMedia];
              ref.read(capturedMediaProvider.notifier).clear();
              sendMedia(capturedMediaCopy);
            },
            child: CapturedMediaDecorator(
              child: Badge(
                label: Text(capturedMedia.length.toString()),
                child: MediaThumbnail(
                  media: capturedMedia.last,
                ),
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
