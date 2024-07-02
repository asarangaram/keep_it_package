import 'package:cl_camera/cl_camera.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DefaultCLCameraThemeData extends CLCameraThemeData {
  DefaultCLCameraThemeData()
      : super(
          iconCamera: MdiIcons.camera,
          iconMicrophone: MdiIcons.microphone,
          iconLocation: MdiIcons.mapMarker,
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
          popMenuAnchor: MdiIcons.dotsVertical,
          popMenuSelectedItem: MdiIcons.checkCircle,
          pagePop: MdiIcons.arrowLeft,
          displayTextStyle: const TextStyle(fontSize: 20),
          displayIconSize: 35,
          textStyle: const TextStyle(fontSize: 16),
        );
}
