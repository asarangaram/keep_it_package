import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'providers/captured_media.dart';

class CapturedMedia extends ConsumerWidget {
  const CapturedMedia({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);
    if (capturedMedia.isEmpty) return Container();
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
        child: CLMediaPreview(
          media: capturedMedia.last,
          keepAspectRatio: false,
        ),
      ),
    );
  }
}
