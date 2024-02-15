import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cl_media/cl_media.dart';
import '../image_services/cl_media_preview.dart';
import 'providers/video_player_state.dart';
import 'views/video_layer.dart';

class VideoPlayer extends ConsumerWidget {
  const VideoPlayer({
    required this.media,
    super.key,
    this.onSelect,
    this.isSelected = false,
  });
  final CLMedia media;
  final void Function()? onSelect;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref.read(videoPlayerStateProvider.notifier).playVideo(media.path);
      });
    }

    final state = ref.watch(videoPlayerStateProvider);
    return switch (state.path == media.path) {
      true => state.controllerAsync.when(
          data: (controller) => VideoLayer(
            controller: controller,
            fit: BoxFit.contain,
          ),
          error: (_, __) => Container(),
          loading: () => Stack(
            children: [
              CLMediaPreview(
                media: media,
              ),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      false => GestureDetector(
          onTap: onSelect,
          child: CLMediaPreview(
            media: media,
          ),
        )
    };
  }
}
