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
    required this.currentResolutionPreset,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final List<CameraDescription> cameras;
  final ResolutionPreset currentResolutionPreset;
  final String directory;
  final void Function() onCancel;
  final void Function(
    List<CLMedia> capturedMedia, {
    required void Function() onDiscard,
  }) onDone;

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

    // resetCameraValues
    _currentZoomLevel = 1.0;

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
        controller = cameraController;
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
      return const CLLoadingView(
        message: 'Initialzing',
      );
    }
    final capturedMedia = ref.watch(capturedMediaProvider);
    return GestureDetector(
      onHorizontalDragEnd: (details) async {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          if (capturedMedia.isNotEmpty) {
            final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmAction(
                      title: 'Discard?',
                      message:
                          'Do you want to discard all the images and video captured?',
                      child: null,
                      onConfirm: ({required confirmed}) =>
                          Navigator.of(context).pop(confirmed),
                    );
                  },
                ) ??
                false;
            if (confirmed) {
              ref.read(capturedMediaProvider.notifier).onDiscard();
              widget.onCancel();
            }
          } else {
            widget.onCancel();
          }
        }
      },
      child: Stack(
        children: [
          CameraBackgroundLayer(controller: controller!),
          SafeArea(
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
                builder: buildBottomControl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startVideoRecording() {
    controller!.onStartVideoRecording(
      onSuccess: () {
        setState(() {
          _isRecordingInProgress = true;
        });
      },
    );
  }

  void stopVideoRecording() => controller!.onStopVideoRecording(
        onSuccess: (videoFilePath) {
          ref.read(capturedMediaProvider.notifier).add(
                CLMedia(
                  path: videoFilePath,
                  type: CLMediaType.video,
                ),
              );
          setState(() {
            _isRecordingInProgress = false;
          });
        },
      );

  void pauseVideoRecording() {
    controller!.onPauseVideoRecording(
      onSuccess: () {
        setState(() {});
      },
    );
  }

  void resumeVideoRecording() {
    controller!.onResumeVideoRecording(
      onSuccess: () {
        setState(() {});
      },
    );
  }

  void takePicture() {
    controller!.onTakePicture(
      onSuccess: (imageFilePath) {
        ref.read(capturedMediaProvider.notifier).add(
              CLMedia(
                path: imageFilePath,
                type: CLMediaType.image,
              ),
            );
      },
    );
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
                                  icon: MdiIcons.stop,
                                  onPressed: stopVideoRecording,
                                )
                              : CameraSelect(
                                  cameras: widget.cameras,
                                  currentCamera: currDescription!,
                                  onNextCamera: () {
                                    setState(() {
                                      _isCameraInitialized = false;
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
                            child: CapturedMedia(
                              directory: widget.directory,
                              onSendCapturedMedia: widget.onDone,
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
}

class ConfirmAction extends StatelessWidget {
  const ConfirmAction({
    required this.title,
    required this.message,
    required this.child,
    required this.onConfirm,
    super.key,
  });

  final String title;
  final String message;
  final Widget? child;
  final void Function({
    required bool confirmed,
  }) onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      title: const Text('Confirm Delete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (child != null)
            SizedBox.square(
              dimension: 200,
              child: child,
            ),
          CLText.large(message),
        ],
      ),
      actions: [
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => onConfirm(confirmed: false),
              child: const Text('No'),
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () => onConfirm(confirmed: true),
            ),
          ],
        ),
      ],
    );
  }
}
