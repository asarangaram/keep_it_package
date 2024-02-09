import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/cl_media.dart';
import '../../views/cl_media_preview.dart';
import '../providers/video_player_state.dart';
import 'video_controls.dart';

class CLVideoPlayer extends ConsumerStatefulWidget {
  const CLVideoPlayer({
    required this.controller,
    this.isPlayingFullScreen = false,
    this.onTapFullScreen,
    super.key,
    this.maxHeight,
    this.onFocus,
  });
  final VideoPlayerController controller;

  final void Function()? onTapFullScreen;
  final bool isPlayingFullScreen;
  final double? maxHeight;
  final void Function()? onFocus;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CLVideoPlayerState();
}

class CLVideoPlayerState extends ConsumerState<CLVideoPlayer> {
  bool isHovering = false;

  Timer? disableControls;
  bool isFocussed = false;

  @override
  void dispose() {
    disableControls?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return SizedBox(
      height: widget.isPlayingFullScreen
          ? null
          : min(
              controller.value.size.height,
              widget.maxHeight ?? MediaQuery.of(context).size.height * 0.7,
            ),
      child: GestureDetector(
        onTap: isHovering
            ? null
            : () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            disableControls?.cancel();
            setState(() {
              isHovering = true;
            });
          },
          onPointerUp: (_) {
            // If the video is playing, pause it.

            disableControls = Timer(
              const Duration(seconds: 3),
              () {
                if (mounted) {
                  setState(() => isHovering = false);
                }
              },
            );
          },
          onPointerHover: (_) {
            setState(() => isHovering = true);
            disableControls?.cancel();
            disableControls = Timer(
              const Duration(seconds: 2),
              () {
                if (mounted) {
                  setState(() => isHovering = false);
                }
              },
            );
          },
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                VideoPlayer(controller),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: (isHovering || !controller.value.isPlaying)
                      ? VideoControls(
                          controller: controller,
                          onTapFullScreen: widget.onTapFullScreen,
                          isPlayingFullScreen: widget.isPlayingFullScreen,
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoViewer extends ConsumerWidget {
  const VideoViewer({required this.media, super.key, this.onSelect});
  final CLMedia media;
  final void Function()? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoPlayerProvider);
    Future<void> onTap() async {
      await ref.read(videoPlayerProvider.notifier).playVideo(media.path);
      onSelect?.call();
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .65,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            if (state.path == media.path)
              state.controllerAsync.when(
                data: (controller) => Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * .65,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VisibilityDetector(
                        key: ValueKey(controller),
                        onVisibilityChanged: (info) {
                          if (context.mounted) {
                            if (info.visibleFraction == 0.0) {
                              if (state.path == media.path) {
                                ref
                                    .read(videoPlayerProvider.notifier)
                                    .stopVideo(media.path);
                              }
                            }
                          }
                        },
                        child: CLVideoPlayer(
                          controller: controller,
                        ),
                      ),
                    ),
                  ),
                ),
                error: (_, __) => Container(),
                loading: () => VideoPreview(
                  media: media,
                  onTap: onTap,
                  overlayChild: const CircularProgressIndicator(),
                ),
              )
            else
              VideoPreview(
                media: media,
                onTap: onTap,
              ),
          ],
        ),
      ),
    );
  }
}
