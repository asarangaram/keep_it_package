import 'package:colan_services/services/video_player_service/views/get_video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';
import 'package:video_player/video_player.dart';

import 'models/video_player_state.dart';
import 'providers/video_player_state.dart';
import 'views/video_controls.dart';
import 'views/video_layer.dart';

enum PlayerServices { player, controlMenu, playStateBuilder }

class VideoPlayerService extends ConsumerWidget {
  const VideoPlayerService.player({
    required this.mediaPath,
    required this.alternate,
    super.key,
    this.onSelect,
    this.autoStart = false,
    this.autoPlay = false,
    this.inplaceControl = false,
  })  : builder = null,
        playerService = PlayerServices.player,
        type = CLMediaType.video;
  const VideoPlayerService.controlMenu({
    required this.mediaPath,
    super.key,
  })  : alternate = null,
        onSelect = null,
        autoStart = false,
        autoPlay = false,
        builder = null,
        playerService = PlayerServices.controlMenu,
        inplaceControl = false,
        type = CLMediaType.video;
  const VideoPlayerService.playStateBuilder({
    required this.mediaPath,
    required this.type,
    required Widget Function({required bool isPlaying}) builder,
    super.key,
  })  : alternate = null,
        onSelect = null,
        autoStart = false,
        autoPlay = false,
        // ignore: prefer_initializing_formals
        builder = builder,
        playerService = PlayerServices.playStateBuilder,
        inplaceControl = false;

  final String mediaPath;
  final CLMediaType type;
  final void Function()? onSelect;
  final bool autoStart;
  final bool autoPlay;
  final Widget? alternate;
  final PlayerServices playerService;
  final Widget Function({required bool isPlaying})? builder;
  final bool inplaceControl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (playerService) {
      case PlayerServices.player:
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (context.mounted && autoStart) {
            await ref.read(videoPlayerStateProvider.notifier).setVideo(
                  mediaPath,
                  autoPlay: autoPlay,
                );
          }
        });

        return GetVideoController(
          builder: (
            VideoPlayerState state,
            VideoPlayerController controller,
          ) {
            if (state.path == mediaPath) {
              return VideoLayer(
                controller: controller,
                inplaceControl: inplaceControl,
              );
            } else {
              return GestureDetector(
                onTap: onSelect,
                child: alternate,
              );
            }
          },
          errorBuilder: (message, e) {
            return GestureDetector(
              onTap: onSelect,
              child: alternate,
            );
          },
          loadingBuilder: () {
            return Stack(
              children: [
                if (alternate != null) alternate!,
                const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        );
      case PlayerServices.controlMenu:
        return GetVideoController(
          builder: (
            VideoPlayerState state,
            VideoPlayerController controller,
          ) {
            if (state.path == mediaPath) {
              return VideoControls(controller: controller);
            } else {
              return Container();
            }
          },
          errorBuilder: (message, e) {
            return Container();
          },
          loadingBuilder: () {
            return Container();
          },
        );
      case PlayerServices.playStateBuilder:
        if (type != CLMediaType.video) {
          return builder!(isPlaying: false);
        }
    }

    return GetVideoController(
      builder: (
        VideoPlayerState state,
        VideoPlayerController controller,
      ) {
        if (state.path == mediaPath) {
          return PlayerStateMonitor(
            controller: controller,
            builder: builder!,
          );
        } else {
          return builder!(isPlaying: false);
        }
      },
      errorBuilder: (message, e) {
        return builder!(isPlaying: false);
      },
      loadingBuilder: () {
        return builder!(isPlaying: false);
      },
    );
  }
}

class PlayerStateMonitor extends StatefulWidget {
  const PlayerStateMonitor({
    required this.controller,
    required this.builder,
    super.key,
  });
  final VideoPlayerController controller;
  final Widget Function({required bool isPlaying}) builder;

  @override
  State<PlayerStateMonitor> createState() => _PlayerStateMonitorState();
}

class _PlayerStateMonitorState extends State<PlayerStateMonitor> {
  @override
  void initState() {
    widget.controller.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  void listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(isPlaying: widget.controller.value.isPlaying);
  }
}
