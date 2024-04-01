import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../image_services/view/cl_media_preview.dart';

class CapturedMedia extends ConsumerWidget {
  const CapturedMedia({required this.directory, super.key});
  final String directory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);
    if (capturedMedia.isEmpty) return Container();
    return InkWell(
      onTap: () {},
      child: Container(
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
          child: (capturedMedia.isEmpty)
              ? null
              : CLMediaPreview(
                  directory: directory,
                  media: capturedMedia.last,
                  keepAspectRatio: false,
                ),
        ),
      ),
    );
  }
}

class CapturedMediaNotifier extends StateNotifier<List<CLMedia>> {
  CapturedMediaNotifier() : super([]);

  void add(CLMedia media) {
    state = [...state, media];
  }
}

final capturedMediaProvider =
    StateNotifierProvider<CapturedMediaNotifier, List<CLMedia>>((ref) {
  return CapturedMediaNotifier();
});
