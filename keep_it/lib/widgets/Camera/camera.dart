import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camera_fullscreen.dart';
import 'mixin.dart';
import 'models/camera_state.dart';
import 'providers/camera_state.dart';

/// Scope of this widget is only to create a CameraState and
/// add it into provider.
class CameraView extends StatefulWidget {
  /// Default Constructor
  const CameraView({
    required this.cameras,
    required this.onError,
    required this.onLoading,
    super.key,
    // ignore: unused_element
    this.defaultCameraIndex = 0,
  });
  final List<CameraDescription> cameras;
  final int defaultCameraIndex;
  final Widget Function(String) onError;
  final Widget Function() onLoading;

  @override
  State<CameraView> createState() {
    return CameraViewState();
  }
}

class CameraViewState extends State<CameraView>
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
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      onAppLifecycleStateChange(
        appState: state,
        description: cameraState?.controller.description ??
            widget.cameras[widget.defaultCameraIndex],
        cameraState: cameraState,
        updateCameraState: onCameraStateChanged,
        onCameraError: onError,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return widget.onError('No camera found.');
    }
    if (cameraState == null) {
      return widget.onLoading();
    }

    final cameraState0 = cameraState!;

    return ProviderScope(
      overrides: [
        cameraStateProvider
            .overrideWith((ref) => CameraStateNotifier(cameraState0)),
      ],
      child: const CameraFullScreen(),
    );
  }
}

const _filePrefix = 'Camera ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
