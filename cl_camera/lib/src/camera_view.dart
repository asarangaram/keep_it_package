// ignore_for_file:  lines_longer_than_80_chars, avoid_print

import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/camera_icons.dart';
import 'models/camera_mode.dart';
import 'models/extensions.dart';
import 'widgets/camera_mode.dart';

import 'widgets/cl_circular_button.dart';

import 'widgets/layer1_background.dart';
import 'widgets/layer2_preview.dart';

class CLCamera extends StatefulWidget {
  const CLCamera({
    required this.cameras,
    required this.currentResolutionPreset,
    required this.onGeneratePreview,
    required this.onCancel,
    required this.cameraIcons,
    required this.onGetPermission,
    required this.onCapture,
    required this.onInitializing,
    required this.onError,
    this.cameraMode = CameraMode.photo,
    this.textStyle,
    super.key,
  });
  final List<CameraDescription> cameras;
  final ResolutionPreset currentResolutionPreset;
  final CameraMode cameraMode;
  final CameraIcons cameraIcons;
  final TextStyle? textStyle;

  final void Function() onCancel;

  final Widget Function() onGeneratePreview;
  final Future<bool> Function() onGetPermission;
  final void Function(String path, {required bool isVideo}) onCapture;
  final Widget Function() onInitializing;
  final void Function(String message, {required dynamic error})? onError;
  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CLCamera> with WidgetsBindingObserver {
  CameraController? controller;
  CameraDescription? currDescription;
  int quarterTurns = 0;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;

  late CameraMode cameraMode; // default
  bool _isRecordingInProgress = false;

  double _minAvailableZoom = 1;
  double _maxAvailableZoom = 1;
  double _currentZoomLevel = 1;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    /*  SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    ); */
    cameraMode = widget.cameraMode;
    getPermissionStatus();

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(restore: true);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );

    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(),
          const Text(
            'Permission denied',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: getPermissionStatus,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Give permission',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (!_isCameraInitialized) {
      return Container(
        decoration: const BoxDecoration(color: Colors.black),
      );
      //  return widget.onInitializing();
    }
    quarterTurns = _getQuarterTurns(_getApplicableOrientation(controller!));
    return Stack(
      children: [
        RotatedBox(
          quarterTurns: quarterTurns,
          child: CameraBackgroundLayer(controller: controller!),
        ),
        SafeArea(
          child: RotatedBox(
            quarterTurns: quarterTurns,
            child: Align(
              alignment: Alignment.topCenter,
              child: CameraPreviewLayer(
                controller: controller!,
                currentZoomLevel: _currentZoomLevel,
                onChangeZoomLevel: (scale) {
                  if (scale < _minAvailableZoom) {
                    scale = _minAvailableZoom;
                  } else if (scale > _maxAvailableZoom) {
                    scale = _maxAvailableZoom;
                  }
                  controller!.setZoomLevel(scale).then((value) {
                    setState(() {
                      _currentZoomLevel = scale;
                    });
                  });
                },
                aspectRatio:
                    _isLandscape(_getApplicableOrientation(controller!))
                        ? controller!.value.aspectRatio
                        : 1 / controller!.value.aspectRatio,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            ignoring: false,
            child: LayoutBuilder(
              builder: buildBottomControl,
            ),
          ),
        ),
      ],
    );
  }

  void startVideoRecording() {
    controller!.onStartVideoRecording(
      onError: widget.onError,
      onSuccess: () {
        if (mounted) {
          setState(() {
            _isRecordingInProgress = true;
          });
        }
      },
    );
  }

  void stopVideoRecording() => controller!.onStopVideoRecording(
        onError: widget.onError,
        onSuccess: (videoFilePath) {
          if (mounted) {
            widget.onCapture(videoFilePath, isVideo: true);
            setState(() {
              _isRecordingInProgress = false;
            });
          }
        },
      );

  void pauseVideoRecording() {
    controller!.onPauseVideoRecording(
      onError: widget.onError,
      onSuccess: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void resumeVideoRecording() {
    controller!.onResumeVideoRecording(
      onError: widget.onError,
      onSuccess: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void takePicture() {
    controller!.onTakePicture(
      onError: widget.onError,
      onSuccess: (imageFilePath) {
        if (mounted) {
          widget.onCapture(imageFilePath, isVideo: false);
        }
      },
    );
  }

  Future<void> getPermissionStatus() async {
    final isGranted = await widget.onGetPermission();

    if (isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      await onNewCameraSelected();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  Future<void> onNewCameraSelected({
    bool restore = false,
  }) async {
    if (restore) {
      currDescription =
          controller?.description ?? currDescription ?? widget.cameras[0];
    } else {
      if (currDescription == null) {
        currDescription = widget.cameras[0];
      } else {
        currDescription = widget.cameras.next(currDescription!);
      }
    }
    final previousCameraController = controller;

    final cameraController = CameraController(
      currDescription!,
      widget.currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    // resetCameraValues
    _currentZoomLevel = 1.0;

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });
    setState(() {
      _isCameraInitialized = false;
    });
    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
    print('size: ${cameraController.value.previewSize}');
    if (mounted) {
      setState(() {
        controller = cameraController;
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  Widget buildBottomControl(BuildContext context, BoxConstraints constrains) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(64),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: constrains.maxWidth,
                  height: kMinInteractiveDimension,
                  child: (_isRecordingInProgress ||
                          (controller?.value.isTakingPicture ?? false))
                      ? null
                      : MenuCameraMode(
                          currMode: cameraMode,
                          onUpdateMode: (mode) {
                            setState(() {
                              cameraMode = mode;
                            });
                          },
                          textStyle: widget.textStyle,
                        ),
                ),
                SizedBox(
                  width: constrains.maxWidth,
                  height: kMinInteractiveDimension * 2,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _isRecordingInProgress
                              ? CircularButton(
                                  quarterTurns: quarterTurns,
                                  icon: Icons.stop,
                                  onPressed: stopVideoRecording,
                                )
                              : CircularButton(
                                  quarterTurns: quarterTurns,
                                  onPressed: onNewCameraSelected,
                                  icon: Icons.cameraswitch,
                                  foregroundColor: Colors.white,
                                  hasDecoration: false,
                                ),
                        ),
                        Expanded(
                          child: CircularButton(
                            quarterTurns: quarterTurns,
                            size: 44,
                            icon: switch ((
                              cameraMode.isVideo,
                              controller!.value.isRecordingVideo,
                              controller!.value.isRecordingPaused
                            )) {
                              (false, _, _) => widget.cameraIcons.imageCamera,
                              (true, false, _) =>
                                widget.cameraIcons.videoCamera,
                              (true, true, false) =>
                                widget.cameraIcons.pauseRecording,
                              (true, true, true) =>
                                widget.cameraIcons.resumeRecording
                            },
                            onPressed: switch ((
                              cameraMode.isVideo,
                              controller!.value.isRecordingVideo,
                              controller!.value.isRecordingPaused
                            )) {
                              (false, _, _) => takePicture,
                              (true, false, _) => startVideoRecording,
                              (true, true, false) => pauseVideoRecording,
                              (true, true, true) => resumeVideoRecording
                            },
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: RotatedBox(
                              quarterTurns: quarterTurns,
                              child: widget.onGeneratePreview(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* Widget _wrapInRotatedBox({
    required Widget child,
    required DeviceOrientation oritentation,
  }) {
    return RotatedBox(
      quarterTurns: _getQuarterTurns(oritentation),
      child: child,
    );
  } */

  bool _isLandscape(DeviceOrientation oritentation) {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ].contains(oritentation);
  }

  int _getQuarterTurns(DeviceOrientation oritentation) {
    final turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 3,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 1,
    };
    return turns[oritentation]!;
  }

  DeviceOrientation _getApplicableOrientation(CameraController controller) {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);
  }
}
