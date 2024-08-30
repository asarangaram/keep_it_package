import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// Currently suppoers only Mute / Unmute
class AudioControlBuilder extends StatefulWidget {
  const AudioControlBuilder({
    required this.builder,
    required this.controller,
    super.key,
  });
  final Widget Function(double voume) builder;
  final VideoPlayerController controller;

  @override
  State<AudioControlBuilder> createState() => _AudioControlBuilderState();
}

class _AudioControlBuilderState extends State<AudioControlBuilder> {
  double volume = 1;
  bool isMuted = false;

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

  void _update() {
    if (!isMuted && widget.controller.value.volume != volume) {
      setState(() {
        volume = widget.controller.value.volume;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMuteToggle,
      child: widget.builder(isMuted ? 0 : volume),
    );
  }

  VideoPlayerValue get video => widget.controller.value;

  void onAdjustVolume(
    double value,
  ) {
    widget.controller.setVolume(value);
    volume = value;
    setState(() {});
  }

  Future<void> onMuteToggle() async {
    setState(() {
      isMuted = !isMuted;
    });

    await widget.controller.setVolume(isMuted ? 0 : volume);

    setState(() {});
  }
}
