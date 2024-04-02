// ignore_for_file:  lines_longer_than_80_chars, avoid_print

import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../extensions.dart';
import '../layers/layer1_background.dart';
import '../layers/layer2_preview.dart';
import '../widgets/camera_mode.dart';
import '../widgets/camera_select.dart';
import '../widgets/captured_media.dart';
import '../widgets/cl_circular_button.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({
    required this.cameras,
    required this.directory,
    this.currentResolutionPreset = ResolutionPreset.high,
    super.key,
  });
  final List<CameraDescription> cameras;
  final String directory;
  final ResolutionPreset currentResolutionPreset;

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver, CameraMixin, SingleTickerProviderStateMixin {
  CameraController? controller;
  CameraDescription? currDescription;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;

  CameraMode cameraMode = CameraMode.photo; // default
  bool _isRecordingInProgress = false;

  double _minAvailableZoom = 1;
  double _maxAvailableZoom = 1;

  final bool allowResolutionChange = false;

  // Current values
  double _currentZoomLevel = 1;

  //final resolutionPresets = ResolutionPreset.values;
  late ResolutionPreset currentResolutionPreset;

  Future<void> getPermissionStatus() async {
    await Permission.camera.request();
    final status = await Permission.camera.status;

    if (status.isGranted) {
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

  Future<void> takePicture() async {
    final cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
    }

    try {
      final file = await cameraController.takePicture();
      ref.read(capturedMediaProvider.notifier).add(
            CLMedia(
              path: file.path,
              type: CLMediaType.image,
            ),
          );
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
    }
  }

  Future<void> startVideoRecording() async {
    final cameraController = controller!;
    if (!cameraController.value.isRecordingVideo) {
      try {
        await cameraController.startVideoRecording();
        setState(() {
          _isRecordingInProgress = true;
        });
      } on CameraException catch (e) {
        print('Error starting to record video: $e');
      }
    }
  }

  Future<void> stopVideoRecording() async {
    if (controller!.value.isRecordingVideo) {
      try {
        final file = await controller!.stopVideoRecording();
        ref.read(capturedMediaProvider.notifier).add(
              CLMedia(
                path: file.path,
                type: CLMediaType.video,
              ),
            );
        setState(() {
          _isRecordingInProgress = false;
        });
      } on CameraException catch (e) {
        print('Error stopping video recording: $e');
      }
    }
  }

  Future<void> pauseVideoRecording() async {
    if (controller!.value.isRecordingVideo) {
      try {
        await controller!.pauseVideoRecording();
        setState(() {});
      } on CameraException catch (e) {
        print('Error pausing video recording: $e');
      }
    }
  }

  Future<void> resumeVideoRecording() async {
    if (controller!.value.isRecordingVideo) {
      try {
        await controller!.resumeVideoRecording();
        setState(() {});
      } on CameraException catch (e) {
        print('Error resuming video recording: $e');
      }
      return;
    }
  }

  Future<void> resetCameraValues() async {
    _currentZoomLevel = 1.0;
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
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    await resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
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
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    currentResolutionPreset = widget.currentResolutionPreset;

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

    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox(
      backgroundColor: Colors.black,
      hasBackground: false,
      child: SafeArea(
        top: false,
        bottom: false,
        child: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? Stack(
                    children: [
                      CameraBackgroundLayer(controller: controller!),
                      SafeArea(
                        bottom: false,
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
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: IgnorePointer(
                          ignoring: false,
                          child: LayoutBuilder(
                            builder: (context, constrains) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(64),
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (_isRecordingInProgress ||
                                              (controller
                                                      ?.value.isTakingPicture ??
                                                  false))
                                            Container()
                                          else
                                            SizedBox(
                                              width: constrains.maxWidth,
                                              height: kMinInteractiveDimension,
                                              child: MenuCameraMode(
                                                currMode: cameraMode,
                                                onUpdateMode: (mode) {
                                                  setState(() {
                                                    cameraMode = mode;
                                                  });
                                                },
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              8,
                                              8,
                                              8,
                                              8,
                                            ),
                                            child: SizedBox(
                                              height:
                                                  kMinInteractiveDimension * 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child:
                                                        _isRecordingInProgress
                                                            ? CircularButton(
                                                                icon: MdiIcons
                                                                    .stop,
                                                                onPressed:
                                                                    stopVideoRecording,
                                                              )
                                                            : CameraSelect(
                                                                cameras: widget
                                                                    .cameras,
                                                                currentCamera:
                                                                    currDescription!,
                                                                onNextCamera:
                                                                    () {
                                                                  setState(() {
                                                                    _isCameraInitialized =
                                                                        false;
                                                                  });
                                                                  onNewCameraSelected();
                                                                },
                                                              ),
                                                  ),
                                                  Expanded(
                                                    child: CircularButton(
                                                      size: 44,
                                                      icon: switch ((
                                                        cameraMode.isVideo,
                                                        controller!.value
                                                            .isRecordingVideo,
                                                        controller!.value
                                                            .isRecordingPaused
                                                      )) {
                                                        (false, _, _) =>
                                                          MdiIcons.camera,
                                                        (true, false, _) =>
                                                          MdiIcons.video,
                                                        (true, true, false) =>
                                                          MdiIcons.pause,
                                                        (true, true, true) =>
                                                          MdiIcons.circle
                                                      },
                                                      onPressed: switch ((
                                                        cameraMode.isVideo,
                                                        controller!.value
                                                            .isRecordingVideo,
                                                        controller!.value
                                                            .isRecordingPaused
                                                      )) {
                                                        (false, _, _) =>
                                                          takePicture,
                                                        (true, false, _) =>
                                                          startVideoRecording,
                                                        (true, true, false) =>
                                                          pauseVideoRecording,
                                                        (true, true, true) =>
                                                          resumeVideoRecording
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child:
                                                          Transform.translate(
                                                        offset: const Offset(
                                                          0,
                                                          -40,
                                                        ),
                                                        child: AspectRatio(
                                                          aspectRatio: 1.0 /
                                                              controller!.value
                                                                  .aspectRatio,
                                                          child: CapturedMedia(
                                                            directory: widget
                                                                .directory,
                                                          ),
                                                        ),
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
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'LOADING',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
            : Column(
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
              ),
      ),
    );
  }
}
