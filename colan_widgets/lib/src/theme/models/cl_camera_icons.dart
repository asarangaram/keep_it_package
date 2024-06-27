// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CLCameraIcons {
  final IconData imageCapture;
  final IconData videoRecordingStart;
  final IconData videoRecordingPause;
  final IconData videoRecordingResume;
  final IconData videoRecordingStop;

  final IconData flashModeOff;
  final IconData flashModeAuto;
  final IconData flashModeAlways;
  final IconData flashModeTorch;

  final IconData recordingAudioOn;
  final IconData recordingAudioOff;
  final IconData switchCamera;

  final IconData exitCamera; // Can we move to Common?

  final IconData invokeCamera;
  CLCameraIcons({
    required this.imageCapture,
    required this.videoRecordingStart,
    required this.videoRecordingPause,
    required this.videoRecordingResume,
    required this.videoRecordingStop,
    required this.flashModeOff,
    required this.flashModeAuto,
    required this.flashModeAlways,
    required this.flashModeTorch,
    required this.recordingAudioOn,
    required this.recordingAudioOff,
    required this.switchCamera,
    required this.exitCamera,
    required this.invokeCamera,
  });
}

class DefaultCLCameraIcons extends CLCameraIcons {
  DefaultCLCameraIcons()
      : super(
          imageCapture: MdiIcons.camera,
          videoRecordingStart: MdiIcons.video,
          videoRecordingPause: MdiIcons.pause,
          videoRecordingResume: MdiIcons.circle,
          videoRecordingStop: Icons.stop,
          flashModeOff: Icons.flash_off,
          flashModeAuto: Icons.flash_auto,
          flashModeAlways: Icons.flash_on,
          flashModeTorch: Icons.highlight,
          recordingAudioOn: MdiIcons.volumeHigh,
          recordingAudioOff: MdiIcons.volumeMute,
          switchCamera: Icons.cameraswitch,
          exitCamera: MdiIcons.arrowLeft,
          invokeCamera: MdiIcons.camera,
        );
}
