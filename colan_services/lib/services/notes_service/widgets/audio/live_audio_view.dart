import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class LiveAudio extends StatelessWidget {
  const LiveAudio({
    required this.recorderController,
    super.key,
  });

  final RecorderController recorderController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AudioWaveforms(
          enableGesture: true,
          size: Size(constraints.maxWidth, constraints.maxHeight - 16),
          recorderController: recorderController,
          waveStyle: const WaveStyle(
            waveColor: Colors.white,
            extendWaveform: true,
            showMiddleLine: false,
          ),
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
        );
      },
    );
  }
}
