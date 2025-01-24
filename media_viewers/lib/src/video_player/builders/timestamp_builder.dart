import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/ext_duration.dart';

class TimeStampBuilder extends StatefulWidget {
  const TimeStampBuilder({
    required this.builder,
    required this.controller,
    super.key,
  });
  final Widget Function({
    required Duration currentPosition,
    required Duration totalDuration,
  }) builder;
  final VideoPlayerController controller;

  @override
  State<TimeStampBuilder> createState() => _TimeStampBuilderState();
}

class _TimeStampBuilderState extends State<TimeStampBuilder> {
  @override
  void initState() {
    widget.controller.addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      currentPosition: video.position,
      totalDuration: video.duration,
    );
  }

  VideoPlayerValue get video => widget.controller.value;
  String get timestamp {
    final currentPosition = video.position;
    return '${currentPosition.timestamp} / ${video.duration.timestamp}';
  }
}
