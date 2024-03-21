// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: lines_longer_than_80_chars

import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'Camera/camera_fullscreen.dart';
import 'Camera/camera_gesture.dart';
import 'Camera/camera_preview.dart';
import 'Camera/camera_preview_core.dart';
import 'Camera/mixin.dart';
import 'Camera/models/camera_state.dart';
import 'Camera/providers/camera_state.dart';
import 'camera_screen.dart';

class CameraView extends StatelessWidget {
  const CameraView({
    required this.cameras,
    required this.onError,
    required this.onLoading,
    super.key,
  });
  final List<CameraDescription> cameras;
  final Widget Function(String) onError;
  final Widget Function() onLoading;

  @override
  Widget build(BuildContext context) {
    try {
      if (cameras.isEmpty) {
        throw Exception('No camera found.');
      }
      return FullscreenLayout(
        useSafeArea: false,
        child: _CameraView(
          cameras: cameras,
          onError: onError,
          onLoading: onLoading,
        ),
      );
    } catch (e) {
      return onError(e.toString());
    }
  }
}

/// Camera example home widget.
class _CameraView extends StatefulWidget {
  /// Default Constructor
  const _CameraView({
    required this.cameras,
    required this.onError,
    required this.onLoading,
    // ignore: unused_element
    this.defaultCameraIndex = 0,
  });
  final List<CameraDescription> cameras;
  final int defaultCameraIndex;
  final Widget Function(String) onError;
  final Widget Function() onLoading;

  @override
  State<_CameraView> createState() {
    return _CameraViewState();
  }
}

class _CameraViewState extends State<_CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin, CameraControl {
  CameraState? cameraState;
  String? errorString;

  bool isFullScreen = true;
  bool isVideoMode = false;

  void onCameraStateChanged(CameraState? newCameraState) {
    cameraState = newCameraState;
    if (mounted) {
      setState(() {});
    }
  }

  void onError(String err) {
    errorString = err;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    CameraState.createAsync(
      widget.cameras[widget.defaultCameraIndex],
      onCameraStateReady: onCameraStateChanged,
      onCameraError: onError,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    cameraState?.dispose();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    onAppLifecycleStateChange(
      appState: appState,
      description: cameraState?.controller.description ??
          widget.cameras[widget.defaultCameraIndex],
      cameraState: cameraState,
      updateCameraState: onCameraStateChanged,
      onCameraError: onError,
    );
  }

  // #enddocregion AppLifecycle
  bool get showControl =>
      !isFullScreen && !cameraState!.controller.value.isRecordingVideo;

  @override
  Widget build(BuildContext context) {
    return widget.onError('This is a error. ' * 5);

    /* final cameraState0 = cameraState!;

    return ProviderScope(
      overrides: [
        cameraStateProvider
            .overrideWith((ref) => CameraStateNotifier(cameraState0)),
      ],
      child: CameraFullScreen(cameraState: cameraState0),
    ); */
  }
}
