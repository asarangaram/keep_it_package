import 'package:cl_camera/cl_camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class DefaultCLCameraIcons extends CLCameraThemeData {
  DefaultCLCameraIcons()
      : super(
          iconCamera: clIcons.camera,
          iconMicrophone: clIcons.microphone,
          iconLocation: clIcons.location,
          imageCapture: clIcons.imageCapture,
          videoRecordingStart: clIcons.videoRecordingStart,
          videoRecordingPause: clIcons.videoRecordingPause,
          videoRecordingResume: clIcons.videoRecordingResume,
          videoRecordingStop: clIcons.videoRecordingStop,
          flashModeOff: clIcons.flashModeOff,
          flashModeAuto: clIcons.flashModeAuto,
          flashModeAlways: clIcons.flashModeAlways,
          flashModeTorch: clIcons.flashModeTorch,
          recordingAudioOn: clIcons.recordingAudioOn,
          recordingAudioOff: clIcons.recordingAudioOff,
          switchCamera: clIcons.switchCamera,
          exitCamera: clIcons.exitCamera,
          invokeCamera: clIcons.invokeCamera,
          popMenuAnchor: clIcons.popMenuAnchor,
          popMenuSelectedItem: clIcons.popMenuSelectedItem,
          pagePop: clIcons.pagePop,
          displayTextStyle: const TextStyle(fontSize: 20),
          displayIconSize: 35,
          textStyle: const TextStyle(fontSize: 16),
        );
}
