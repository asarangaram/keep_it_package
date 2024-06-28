// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

@immutable
class CLCameraThemeData {
  final IconData iconCamera;
  final IconData iconMicrophone;
  final IconData iconLocation;

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
  final IconData popMenuAnchor;
  final IconData popMenuSelectedItem;
  final IconData pagePop;

  final TextStyle displayTextStyle;
  final double displayIconSize;
  final TextStyle textStyle;

  const CLCameraThemeData({
    required this.iconCamera,
    required this.iconMicrophone,
    required this.iconLocation,
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
    required this.popMenuAnchor,
    required this.popMenuSelectedItem,
    required this.pagePop,
    required this.displayTextStyle,
    required this.displayIconSize,
    required this.textStyle,
  });

  CLCameraThemeData copyWith({
    IconData? iconCamera,
    IconData? iconMicrophone,
    IconData? iconLocation,
    IconData? imageCapture,
    IconData? videoRecordingStart,
    IconData? videoRecordingPause,
    IconData? videoRecordingResume,
    IconData? videoRecordingStop,
    IconData? flashModeOff,
    IconData? flashModeAuto,
    IconData? flashModeAlways,
    IconData? flashModeTorch,
    IconData? recordingAudioOn,
    IconData? recordingAudioOff,
    IconData? switchCamera,
    IconData? exitCamera,
    IconData? invokeCamera,
    IconData? popMenuAnchor,
    IconData? popMenuSelectedItem,
    IconData? pagePop,
    TextStyle? displayTextStyle,
    double? displayIconSize,
    TextStyle? textStyle,
  }) {
    return CLCameraThemeData(
      iconCamera: iconCamera ?? this.iconCamera,
      iconMicrophone: iconMicrophone ?? this.iconMicrophone,
      iconLocation: iconLocation ?? this.iconLocation,
      imageCapture: imageCapture ?? this.imageCapture,
      videoRecordingStart: videoRecordingStart ?? this.videoRecordingStart,
      videoRecordingPause: videoRecordingPause ?? this.videoRecordingPause,
      videoRecordingResume: videoRecordingResume ?? this.videoRecordingResume,
      videoRecordingStop: videoRecordingStop ?? this.videoRecordingStop,
      flashModeOff: flashModeOff ?? this.flashModeOff,
      flashModeAuto: flashModeAuto ?? this.flashModeAuto,
      flashModeAlways: flashModeAlways ?? this.flashModeAlways,
      flashModeTorch: flashModeTorch ?? this.flashModeTorch,
      recordingAudioOn: recordingAudioOn ?? this.recordingAudioOn,
      recordingAudioOff: recordingAudioOff ?? this.recordingAudioOff,
      switchCamera: switchCamera ?? this.switchCamera,
      exitCamera: exitCamera ?? this.exitCamera,
      invokeCamera: invokeCamera ?? this.invokeCamera,
      popMenuAnchor: popMenuAnchor ?? this.popMenuAnchor,
      popMenuSelectedItem: popMenuSelectedItem ?? this.popMenuSelectedItem,
      pagePop: pagePop ?? this.pagePop,
      displayTextStyle: displayTextStyle ?? this.displayTextStyle,
      displayIconSize: displayIconSize ?? this.displayIconSize,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  String toString() {
    return 'CLCameraThemeData(iconCamera: $iconCamera, iconMicrophone: $iconMicrophone, iconLocation: $iconLocation, imageCapture: $imageCapture, videoRecordingStart: $videoRecordingStart, videoRecordingPause: $videoRecordingPause, videoRecordingResume: $videoRecordingResume, videoRecordingStop: $videoRecordingStop, flashModeOff: $flashModeOff, flashModeAuto: $flashModeAuto, flashModeAlways: $flashModeAlways, flashModeTorch: $flashModeTorch, recordingAudioOn: $recordingAudioOn, recordingAudioOff: $recordingAudioOff, switchCamera: $switchCamera, exitCamera: $exitCamera, invokeCamera: $invokeCamera, popMenuAnchor: $popMenuAnchor, popMenuSelectedItem: $popMenuSelectedItem, pagePop: $pagePop, displayTextStyle: $displayTextStyle, displayIconSize: $displayIconSize, textStyle: $textStyle)';
  }

  @override
  bool operator ==(covariant CLCameraThemeData other) {
    if (identical(this, other)) return true;

    return other.iconCamera == iconCamera &&
        other.iconMicrophone == iconMicrophone &&
        other.iconLocation == iconLocation &&
        other.imageCapture == imageCapture &&
        other.videoRecordingStart == videoRecordingStart &&
        other.videoRecordingPause == videoRecordingPause &&
        other.videoRecordingResume == videoRecordingResume &&
        other.videoRecordingStop == videoRecordingStop &&
        other.flashModeOff == flashModeOff &&
        other.flashModeAuto == flashModeAuto &&
        other.flashModeAlways == flashModeAlways &&
        other.flashModeTorch == flashModeTorch &&
        other.recordingAudioOn == recordingAudioOn &&
        other.recordingAudioOff == recordingAudioOff &&
        other.switchCamera == switchCamera &&
        other.exitCamera == exitCamera &&
        other.invokeCamera == invokeCamera &&
        other.popMenuAnchor == popMenuAnchor &&
        other.popMenuSelectedItem == popMenuSelectedItem &&
        other.pagePop == pagePop &&
        other.displayTextStyle == displayTextStyle &&
        other.displayIconSize == displayIconSize &&
        other.textStyle == textStyle;
  }

  @override
  int get hashCode {
    return iconCamera.hashCode ^
        iconMicrophone.hashCode ^
        iconLocation.hashCode ^
        imageCapture.hashCode ^
        videoRecordingStart.hashCode ^
        videoRecordingPause.hashCode ^
        videoRecordingResume.hashCode ^
        videoRecordingStop.hashCode ^
        flashModeOff.hashCode ^
        flashModeAuto.hashCode ^
        flashModeAlways.hashCode ^
        flashModeTorch.hashCode ^
        recordingAudioOn.hashCode ^
        recordingAudioOff.hashCode ^
        switchCamera.hashCode ^
        exitCamera.hashCode ^
        invokeCamera.hashCode ^
        popMenuAnchor.hashCode ^
        popMenuSelectedItem.hashCode ^
        pagePop.hashCode ^
        displayTextStyle.hashCode ^
        displayIconSize.hashCode ^
        textStyle.hashCode;
  }

  IconData iconPermission(Permission permission) {
    return switch (permission) {
      Permission.camera => iconCamera,
      Permission.microphone => iconMicrophone,
      Permission.location => iconLocation,
      _ => Icons.device_unknown_outlined // Should not occur
    };
  }
}
