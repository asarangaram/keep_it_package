// ignore_for_file: avoid_print, lines_longer_than_80_chars, unused_import

import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../extensions.dart';
import '../image_services/view/cl_media_preview.dart';
import '../widgets/camera_gesture.dart';
import '../widgets/camera_selectors.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    required this.cameras,
    required this.directory,
    super.key,
  });
  final List<CameraDescription> cameras;
  final String directory;

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  CameraDescription? currDescription;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableExposureOffset = 0;
  double _maxAvailableExposureOffset = 0;
  double _minAvailableZoom = 1;
  double _maxAvailableZoom = 1;
  final bool _cameraAim = false;

  // Current values
  double _currentZoomLevel = 1;
  double _currentExposureOffset = 0;
  FlashMode? _currentFlashMode;

  List<CLMedia> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

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

  Future<void> refreshAlreadyCapturedImages(String recentFileName) async {
    print(recentFileName);
    if (recentFileName.contains('.mp4')) {
      allFileList.add(CLMedia(path: recentFileName, type: CLMediaType.video));
    } else {
      allFileList.add(CLMedia(path: recentFileName, type: CLMediaType.image));
    }

    setState(() {});
  }

  Future<XFile?> takePicture() async {
    final cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    final cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      final file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  Future<void> resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
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
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

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
    // Hide the status bar in Android
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

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
    controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CLFullscreenBox(
        backgroundColor: Colors.black,
        child: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? Column(
                    children: [
                      AspectRatio(
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
                                    onTapDown: (details) =>
                                        onViewFinderTap(details, constraints),
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
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                  ),
                                  child: DropdownButton<ResolutionPreset>(
                                    dropdownColor: Colors.black87,
                                    underline: Container(),
                                    value: currentResolutionPreset,
                                    items: [
                                      for (final ResolutionPreset preset
                                          in resolutionPresets)
                                        DropdownMenuItem(
                                          value: preset,
                                          child: Text(
                                            preset
                                                .toString()
                                                .split('.')[1]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        currentResolutionPreset = value!;
                                        _isCameraInitialized = false;
                                      });
                                      onNewCameraSelected(restore: true);
                                    },
                                    hint: const Text('Select item'),
                                  ),
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
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: constrains.maxWidth,
                                                    height:
                                                        kMinInteractiveDimension,
                                                    child: CameraMode(
                                                      menuItems: [
                                                        CLMenuItem(
                                                          title: 'Photo',
                                                          icon: Icons.camera,
                                                          onTap: () async {
                                                            setState(() {
                                                              _isVideoCameraSelected =
                                                                  false;
                                                            });
                                                            return true;
                                                          },
                                                        ),
                                                        CLMenuItem(
                                                          title: 'Video',
                                                          icon: Icons
                                                              .video_camera_back,
                                                          onTap: () async {
                                                            setState(() {
                                                              _isVideoCameraSelected =
                                                                  true;
                                                            });
                                                            return true;
                                                          },
                                                        ),
                                                      ],
                                                      currIndex:
                                                          _isVideoCameraSelected
                                                              ? 1
                                                              : 0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              8,
                                              16,
                                              8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: _isRecordingInProgress
                                                      ? () async {
                                                          if (controller!.value
                                                              .isRecordingPaused) {
                                                            await resumeVideoRecording();
                                                          } else {
                                                            await pauseVideoRecording();
                                                          }
                                                        }
                                                      : () {
                                                          setState(() {
                                                            _isCameraInitialized =
                                                                false;
                                                          });
                                                          onNewCameraSelected();
                                                          setState(() {
                                                            _isRearCameraSelected =
                                                                !_isRearCameraSelected;
                                                          });
                                                        },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.circle,
                                                        color: Colors.black38,
                                                        size: 60,
                                                      ),
                                                      if (_isRecordingInProgress)
                                                        controller!.value
                                                                .isRecordingPaused
                                                            ? const Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                color: Colors
                                                                    .white,
                                                                size: 30,
                                                              )
                                                            : const Icon(
                                                                Icons.pause,
                                                                color: Colors
                                                                    .white,
                                                                size: 30,
                                                              )
                                                      else
                                                        Icon(
                                                          _isRearCameraSelected
                                                              ? Icons
                                                                  .camera_front
                                                              : Icons
                                                                  .camera_rear,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: _isVideoCameraSelected
                                                      ? () async {
                                                          if (_isRecordingInProgress) {
                                                            final rawVideo =
                                                                await stopVideoRecording();
                                                            if (rawVideo !=
                                                                null) {
                                                              await refreshAlreadyCapturedImages(
                                                                rawVideo.path,
                                                              );
                                                            }
                                                          } else {
                                                            await startVideoRecording();
                                                          }
                                                        }
                                                      : () async {
                                                          if (!controller!.value
                                                              .isTakingPicture) {
                                                            final rawImage =
                                                                await takePicture();

                                                            if (rawImage !=
                                                                null) {
                                                              await refreshAlreadyCapturedImages(
                                                                rawImage.path,
                                                              );
                                                            }
                                                          }
                                                        },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.circle,
                                                        color:
                                                            _isVideoCameraSelected
                                                                ? Colors.white
                                                                : Colors
                                                                    .white38,
                                                        size: 80,
                                                      ),
                                                      Icon(
                                                        Icons.circle,
                                                        color:
                                                            _isVideoCameraSelected
                                                                ? Colors.red
                                                                : Colors.white,
                                                        size: 65,
                                                      ),
                                                      if (_isVideoCameraSelected &&
                                                          _isRecordingInProgress)
                                                        const Icon(
                                                          Icons.stop_rounded,
                                                          color: Colors.white,
                                                          size: 32,
                                                        )
                                                      else
                                                        Container(),
                                                    ],
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {},
                                                  child: Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        10,
                                                      ),
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8,
                                                      ),
                                                      child: (allFileList
                                                              .isEmpty)
                                                          ? null
                                                          : CLMediaPreview(
                                                              directory: widget
                                                                  .directory,
                                                              media: allFileList
                                                                  .last,
                                                            ),
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
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _currentFlashMode = FlashMode.off;
                                        });
                                        await controller!.setFlashMode(
                                          FlashMode.off,
                                        );
                                      },
                                      child: Icon(
                                        Icons.flash_off,
                                        color:
                                            _currentFlashMode == FlashMode.off
                                                ? Colors.amber
                                                : Colors.white,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _currentFlashMode = FlashMode.auto;
                                        });
                                        await controller!.setFlashMode(
                                          FlashMode.auto,
                                        );
                                      },
                                      child: Icon(
                                        Icons.flash_auto,
                                        color:
                                            _currentFlashMode == FlashMode.auto
                                                ? Colors.amber
                                                : Colors.white,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _currentFlashMode = FlashMode.always;
                                        });
                                        await controller!.setFlashMode(
                                          FlashMode.always,
                                        );
                                      },
                                      child: Icon(
                                        Icons.flash_on,
                                        color: _currentFlashMode ==
                                                FlashMode.always
                                            ? Colors.amber
                                            : Colors.white,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _currentFlashMode = FlashMode.torch;
                                        });
                                        await controller!.setFlashMode(
                                          FlashMode.torch,
                                        );
                                      },
                                      child: Icon(
                                        Icons.highlight,
                                        color:
                                            _currentFlashMode == FlashMode.torch
                                                ? Colors.amber
                                                : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
