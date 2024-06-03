// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera/camera.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cl_camera.dart';
import 'widgets/camera_mode.dart';
import 'widgets/cl_circular_button.dart';

/// Camera example home widget.
class CLCamera extends StatefulWidget {
  const CLCamera({
    required this.cameras,
    required this.cameraIcons,
    required this.previewWidget,
    required this.onCapture,
    this.textStyle,
    this.cameraMode = CameraMode.photo,
    this.onError,
    super.key,
  });
  final List<CameraDescription> cameras;
  final TextStyle? textStyle;
  final CameraMode cameraMode;
  final CameraIcons cameraIcons;
  final void Function(String message, {required dynamic error})? onError;
  final Widget previewWidget;
  final void Function(String, {required bool isVideo}) onCapture;

  @override
  State<CLCamera> createState() {
    return _CLCameraState();
  }
}

class _CLCameraState extends State<CLCamera>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;

  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double minAvailableExposureOffset = 0;
  double maxAvailableExposureOffset = 0;
  final double currentExposureOffset = 0;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> focusModeControlRowAnimation;
  double _minAvailableZoom = 1;
  double _maxAvailableZoom = 1;
  double _currentScale = 1;
  double _baseScale = 1;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  late CameraMode cameraMode; // default
  bool _isRecordingInProgress = false;
  CameraDescription? currDescription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    cameraMode = widget.cameraMode;
    onNewCameraSelected();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  // #docregion AppLifecycle
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
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final quarterTurns = getQuarterTurns(getApplicableOrientation(controller!));
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(child: _cameraPreviewWidget()),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: kMinInteractiveDimension,
                  child: MenuCameraMode(
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
                  width: constraints.maxWidth,
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
                              child: widget.previewWidget,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _cameraPreviewWidget() {
    final cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onTapDown: (TapDownDetails details) =>
                    onViewFinderTap(details, constraints),
              );
            },
          ),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController
      ..setExposurePoint(offset)
      ..setFocusPoint(offset);
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

    if (controller != null) {
      await controller!.setDescription(currDescription!);
      final cameraController = controller!;
      try {
        await cameraController.initialize();
        await Future.wait(<Future<Object?>>[
          // The exposure mode is currently not supported on the web.
          ...!kIsWeb
              ? <Future<Object?>>[
                  cameraController.getMinExposureOffset().then(
                        (double value) => minAvailableExposureOffset = value,
                      ),
                  cameraController.getMaxExposureOffset().then(
                        (double value) => maxAvailableExposureOffset = value,
                      ),
                ]
              : <Future<Object?>>[],
          cameraController.getMaxZoomLevel().then((double value) {
            _maxAvailableZoom = value;
            return null;
          }),
          cameraController
              .getMinZoomLevel()
              .then((double value) => _minAvailableZoom = value),
        ]);
      } on CameraException catch (e) {
        switch (e.code) {
          case 'CameraAccessDenied':
            showInSnackBar('You have denied camera access.');
          case 'CameraAccessDeniedWithoutPrompt':
            // iOS only
            showInSnackBar(
              'Please go to Settings app to enable camera access.',
            );
          case 'CameraAccessRestricted':
            // iOS only
            showInSnackBar('Camera access is restricted.');
          case 'AudioAccessDenied':
            showInSnackBar('You have denied audio access.');
          case 'AudioAccessDeniedWithoutPrompt':
            // iOS only
            showInSnackBar('Please go to Settings app to enable audio access.');
          case 'AudioAccessRestricted':
            // iOS only
            showInSnackBar('Audio access is restricted.');
          default:
            showInSnackBar(e.toString());
            break;
        }
      }
      setState(() {});
    } else {
      return initializeCameraController(currDescription!);
    }
  }

  Future<void> initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    final cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
          'Camera error ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController.getMinExposureOffset().then(
                      (double value) => minAvailableExposureOffset = value,
                    ),
                cameraController.getMaxExposureOffset().then(
                      (double value) => maxAvailableExposureOffset = value,
                    ),
              ]
            : <Future<Object?>>[],
        cameraController.getMaxZoomLevel().then((double value) {
          _maxAvailableZoom = value;
          return null;
        }),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          showInSnackBar(e.toString());
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  int getQuarterTurns(DeviceOrientation oritentation) {
    final turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 3,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 1,
    };
    return turns[oritentation]!;
  }

  DeviceOrientation getApplicableOrientation(CameraController controller) {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);
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
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  // This enum is from a different package, so a new value could be added at
  // any time. The example should keep working if that happens.
  // ignore: dead_code
  return Icons.camera;
}
