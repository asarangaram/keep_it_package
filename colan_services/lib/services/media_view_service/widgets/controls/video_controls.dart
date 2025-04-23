import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControls extends StatelessWidget {
  const VideoControls({
    required this.playerControls,
    required this.playStatus,
    super.key,
  });

  final VideoPlayerControls playerControls;
  final VideoPlayerValue playStatus;

  @override
  Widget build(BuildContext context) {
    return const Text('Implement here');
  }
}
