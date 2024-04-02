// ignore_for_file:  lines_longer_than_80_chars, avoid_print

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../extensions.dart';
import '../widgets/camera_gesture.dart';
import '../widgets/camera_mode.dart';
import '../widgets/camera_select.dart';
import '../widgets/captured_media.dart';
import '../widgets/cl_circular_button.dart';
import '../widgets/flash_control.dart';

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
  final bool _cameraAim = false;
  final bool allowResolutionChange = false;

  // Current values
  double _currentZoomLevel = 1;

  bool showSettings = false;
  late AnimationController settingsController;
  late Animation<double> settingsAnimation;

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

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  @override
  void initState() {
    settingsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    settingsAnimation =
        Tween<double>(begin: 0, end: 1).animate(settingsController);

    // Hide the status bar in Android

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
    settingsController.dispose();
    controller?.dispose();
    super.dispose();
  }

  void toggleSettingsVisibility() {
    setState(() {
      showSettings = !showSettings;
    });
    if (showSettings) {
      settingsController.forward();
    } else {
      settingsController.reverse();
    }
  }

  void hideSettings() {
    if (showSettings == true) {
      setState(() {
        showSettings = false;
      });
      if (showSettings) {
        settingsController.forward();
      } else {
        settingsController.reverse();
      }
    }
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
                      controller!.buildPreview(),
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.black.withOpacity(
                              0.5,
                            ), // Adjust opacity as needed
                          ),
                        ),
                      ),
                      Center(
                        child: AspectRatio(
                          aspectRatio: 1 / controller!.value.aspectRatio,
                          child: Stack(
                            children: [
                              CameraPreview(
                                controller!,
                                child: LayoutBuilder(
                                  builder: (
                                    BuildContext context,
                                    BoxConstraints constraints,
                                  ) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapDown: (details) => onViewFinderTap(
                                        details,
                                        constraints,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              CameraGesture(
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
                              if (_cameraAim)
                                IgnorePointer(
                                  ignoring: false,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/camera_aim.png',
                                      color: Colors.greenAccent,
                                      width: 150,
                                      height: 150,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, top: 8),
                                child: FlashControl(controller: controller!),
                              ),
                            ],
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

  Positioned buildSettings() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: settingsAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: settingsAnimation.value,
            child: Transform.translate(
              offset: Offset(
                0,
                50 * (1 - settingsAnimation.value),
              ),
              child: CameraSettings(
                onClose: hideSettings,
                controller: controller!,
                children: [
                  FlashControl(
                    controller: controller!,
                  ),
                  CameraSelect(
                    cameras: widget.cameras,
                    currentCamera: currDescription!,
                    onNextCamera: () {
                      setState(() {
                        _isCameraInitialized = false;
                      });
                      onNewCameraSelected();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CameraSettings extends StatelessWidget {
  const CameraSettings({
    required this.onClose,
    required this.controller,
    required this.children,
    super.key,
  });
  final VoidCallback onClose;
  final CameraController controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const foregroundColor = Colors.white;
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.down,
      onDismissed: (direction) {
        if (direction == DismissDirection.down) {
          onClose();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: foregroundColor)),
          /* borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ), */
          color: Colors.black,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: CLButtonIcon.standard(
                Icons.close,
                onTap: onClose,
                color: foregroundColor,
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          8,
                                          16,
                                          8,
                                        ),
                                        child: Row(
                                          children: [
                                            
                                            
                                            if (allowResolutionChange)
                                              CameraResolution(
                                                currResolution: controller!
                                                    .value.previewSize,
                                                onNextResolution: () {
                                                  setState(() {
                                                    currentResolutionPreset =
                                                        ResolutionPreset.values
                                                            .next(
                                                      controller!
                                                          .resolutionPreset,
                                                    );
                                                    _isCameraInitialized =
                                                        false;
                                                  });
                                                  onNewCameraSelected(
                                                    restore: true,
                                                  );
                                                },
                                              )
                                            else
                                              Container(),
                                          ]
                                              .map(
                                                (e) => Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4,
                                                    ),
                                                    child: e,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
 */
