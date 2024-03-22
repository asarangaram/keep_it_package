import 'dart:ui';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/camera_state.dart';

class CameraStateNotifier extends StateNotifier<CameraState> {
  CameraStateNotifier(super.cameraState) {
    state.controller.addListener(listener);
  }

  @override
  void dispose() {
    state.controller.removeListener(listener);
    super.dispose();
  }

  void listener() {
    final controller = state.controller.value;

    _infoLogger(controller.toString());
    bool? isRecordingVideo0;
    bool? isRecordingPaused0;
    bool? isTakingPicture0;

    isRecordingVideo0 = controller.isRecordingVideo;
    isRecordingPaused0 =
        controller.isRecordingVideo && controller.isRecordingPaused;
    isTakingPicture0 = controller.isTakingPicture;

    isRecordingVideo0 = (isRecordingVideo0 == state.isRecordingVideo)
        ? null
        : isRecordingVideo0;
    isRecordingPaused0 = (isRecordingPaused0 = state.isRecordingPaused)
        ? null
        : isRecordingPaused0;
    isTakingPicture0 =
        (isTakingPicture0 == state.isTakingPicture) ? null : isTakingPicture0;
    _infoLogger('isRecordingVideo:$isRecordingVideo0, '
        'isRecordingPaused:$isRecordingPaused0 '
        'isTakingPicture:$isTakingPicture0');

    if ([isRecordingVideo0, isRecordingPaused0, isTakingPicture0]
        .any((e) => e != null)) {
      state = state.copyWith(
        isTakingPicture: isTakingPicture0,
        isRecordingVideo: isRecordingVideo0,
        isRecordingPaused: isRecordingPaused0,
      );
    }
  }

  Future<void> setZoomLevel(double value) async {
    state = await state.setZoomLevel(value);
  }

  Future<void> setFocusPoint(Offset offset) async {
    state = await state.setFocusPoint(offset);
  }

  Future<void> setPhotoMode() async {
    state = state.copyWith(isVideo: false);
  }

  Future<void> setVideoMode() async {
    state = state.copyWith(isVideo: true);
  }

  Future<void> primaryButtonAction() async {
    try {
      if (!state.isVideo && !state.isTakingPicture) {
        _infoLogger('Action: takePicture');
        final xFile = await state.controller.takePicture();
        return;
      } else if (state.isVideo) {
        if (!state.isRecordingVideo) {
          _infoLogger('Action: startVideoRecording');
          await state.controller.startVideoRecording();
          return;
        } else {
          if (state.isRecordingPaused) {
            _infoLogger('Action: resumeVideoRecording');
            await state.controller.resumeVideoRecording();
            return;
          } else {
            _infoLogger('Action: pauseVideoRecording');
            await state.controller.pauseVideoRecording();
            return;
          }
        }
      }
    } catch (e) {
      _infoLogger('Error: $e');
    }
    _infoLogger('No Action taken');
  }

  Future<void> secondaryButtonAction() async {
    if (state.controller.value.isRecordingVideo) {
      _infoLogger('Action: stopVideoRecording');
      final xFile = await state.controller.stopVideoRecording();
    }
  }
}

final cameraStateProvider =
    StateNotifierProvider<CameraStateNotifier, CameraState>((ref) {
  throw Exception('Use within CameraView widget');
});

const _filePrefix = 'Camera ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
