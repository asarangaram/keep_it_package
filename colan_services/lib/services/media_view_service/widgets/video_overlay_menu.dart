import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'controls/play_time_slider.dart';
import 'controls/toggle_audio_mute.dart';
import 'controls/toggle_fullscreen.dart';
import 'controls/toggle_play.dart';

class VideoOverlayMenu extends StatelessWidget {
  const VideoOverlayMenu({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.black54,
          width: constraints.maxWidth, // Matches media width
          child: ShadTheme(
            data: ShadTheme.of(context).copyWith(
              textTheme: ShadTheme.of(context).textTheme.copyWith(
                    small: ShadTheme.of(context).textTheme.small.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                  ),
              ghostButtonTheme: const ShadButtonTheme(
                foregroundColor: Colors.white,
                size: ShadButtonSize.sm,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PlayTimeSlider(uri: uri),
                Row(
                  children: [
                    FittedBox(child: OnToggleVideoPlay(uri: uri)),
                    FittedBox(child: OnToggleAudioMute(uri: uri)),
                    const Spacer(),
                    const FittedBox(child: OnToggleFullScreen()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
