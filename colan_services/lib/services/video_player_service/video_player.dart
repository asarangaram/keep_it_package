import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'providers/video_player_state.dart';
import 'views/video_layer.dart';

class VideoPlayerService extends ConsumerWidget {
  const VideoPlayerService({
    required this.media,
    required this.alternate,
    super.key,
    this.onSelect,
    this.isSelected = false,
  });
  final CLMedia media;
  final void Function()? onSelect;
  final bool isSelected;

  final Widget alternate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted) {
          await ref
              .read(videoPlayerStateProvider.notifier)
              .playVideo(media.path);
        }
      });
    }

    final state = ref.watch(videoPlayerStateProvider);
    final formattedDate = media.originalDate == null
        ? 'Err: No date'
        : DateFormat('dd MMMM yyyy').format(media.originalDate!);
    return switch (state.path == media.path) {
      true => state.controllerAsync.when(
          data: (controller) => VideoLayer(
            controller: controller,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                child: CLText.standard(
                  formattedDate,
                  textAlign: TextAlign.start,
                  color:
                      Theme.of(context).colorScheme.background.withAlpha(192),
                ),
              ),
            ],
          ),
          error: (_, __) => Container(),
          loading: () => Stack(
            children: [
              alternate,
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      false => GestureDetector(
          onTap: onSelect,
          child: alternate,
        )
    };
  }
}
