// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera/camera.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../cl_camera.dart';
import 'widgets/camera_mode.dart';
import 'widgets/cl_circular_button.dart';
import 'widgets/flash_control.dart';

/// Camera example home widget.
class CLCamera extends StatefulWidget {
  const CLCamera({
    required this.cameras,
    required this.previewWidget,
    required this.onCapture,
    this.textStyle,
    this.cameraMode = CameraMode.photo,
    this.onError,
    super.key,
    this.onCancel,
  });
  final List<CameraDescription> cameras;
  final TextStyle? textStyle;
  final CameraMode cameraMode;

  final void Function(String message, {required dynamic error})? onError;
  final Widget previewWidget;
  final void Function(String, {required bool isVideo}) onCapture;
  final VoidCallback? onCancel;

  @override
  State<CLCamera> createState() {
    return _CLCameraState();
  }
}

class _CLCameraState extends State<CLCamera> with WidgetsBindingObserver {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;

  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double minAvailableExposureOffset = 0;
  double maxAvailableExposureOffset = 0;
  final double currentExposureOffset = 0;

  double _minAvailableZoom = 1;
  double _maxAvailableZoom = 1;
  double _currentScale = 1;
  double _baseScale = 1;

  late CameraMode cameraMode;
  bool _isRecordingInProgress = false;
  CameraDescription? currDescription;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cameraMode = widget.cameraMode;
    onNewCameraSelected();
  }

  @override
  void dispose() {
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);

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
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        children: <Widget>[
          Row(
            children: [
              if (widget.onCancel != null)
                IconButton(
                  icon: Icon(MdiIcons.arrowLeft),
                  onPressed: widget.onCancel,
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlashControl(
                      controller: controller!,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color:
                        controller != null && controller!.value.isRecordingVideo
                            ? Colors.redAccent
                            : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
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
                          const EdgeInsets.only(left: 8, right: 8, bottom: 16),
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
                                (false, _, _) => MdiIcons.camera,
                                (true, false, _) => MdiIcons.video,
                                (true, true, false) => MdiIcons.pause,
                                (true, true, true) => MdiIcons.circle
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
          const SizedBox(
            height: 16,
          ),
        ],
      ),
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
