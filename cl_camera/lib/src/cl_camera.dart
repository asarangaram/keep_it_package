// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:cl_camera/src/models/camera_config.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../cl_camera.dart';
import 'widgets/camera_mode.dart';
import 'widgets/camera_settings.dart';
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

  //final List<CameraDescription> cameras;
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

class _CLCameraState extends State<CLCamera>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;

  double minAvailableExposureOffset = 0;
  double maxAvailableExposureOffset = 0;
  double currentExposureOffset = 0;

  double _minAvailableZoom = 1;
  double _maxAvailableZoom = 1;
  double _currentScale = 1;
  double _baseScale = 1;

  late CameraMode cameraMode;
  bool _isRecordingInProgress = false;
  CameraDescription? currDescription;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  CameraSettings? cameraSettings;
  late AnimationController cameraSettingsController;
  late Animation<double> cameraSettingsAnimation;
  late final CameraDescription defaultCamera;
  CameraConfig config = const CameraConfig();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cameraMode = widget.cameraMode;
    cameraSettingsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    cameraSettingsAnimation = CurvedAnimation(
      parent: cameraSettingsController,
      curve: Curves.easeInCubic,
    );

    swapFrontBack();
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    WidgetsBinding.instance.removeObserver(this);
    cameraSettingsController.dispose();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final cameraController = controller;
      // App state changed before we got the chance to initialize.
      if (cameraController == null || !cameraController.value.isInitialized) {
        return;
      }
      controller = null;
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      swapFrontBack(restore: true);
    }
  }

  void animate(CameraSettings? value) {
    if (value == null) {
      cameraSettingsController.reverse();
    } else {
      cameraSettingsController.forward();
    }
  }

  void showSettings(CameraSettings value) {
    cameraSettings = (cameraSettings == value) ? null : value;
    animate(cameraSettings);
    setState(() {});
  }

  void closeSettings() {
    if (cameraSettings == null) return;
    cameraSettings = null;
    animate(cameraSettings);
    setState(() {});
  }

  Widget cameraSettingWidget(CameraController? cameraController) {
    if (cameraController == null) {
      return const SizedBox.shrink();
    }
    return SizeTransition(
      sizeFactor: cameraSettingsAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Expanded(child: cameraSettingsMenu(cameraController))],
        ),
      ),
    );
  }

  Widget cameraSettingsMenu(CameraController cameraController) {
    {
      return Row(
        children: [
          Expanded(
            child: switch (cameraSettings) {
              CameraSettings.exposureMode =>
                exposureModeSettings(cameraController),
              null => Container(),
              CameraSettings.cameraSelection => cameraSelector(widget.cameras),
              CameraSettings.focusMode => focusModeSettings(cameraController),
            },
          ),
          IconButton(onPressed: closeSettings, icon: const Icon(Icons.check)),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Cl Camera is build');
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
                    CameraSettingsHandler(
                      currentSelection: cameraSettings,
                      onSelection: showSettings,
                    ),
                  ],
                ),
              ),
            ],
          ),
          cameraSettingWidget(controller),
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
                                    onPressed: swapFrontBack,
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
    /* ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message))); */
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

  CameraDescription get backCamera => widget.cameras
      .where(
        (e) => e.lensDirection == CameraLensDirection.back,
      )
      .toList()[config.defaultBackCameraIndex];
  CameraDescription get frontCamera => widget.cameras
      .where(
        (e) => e.lensDirection == CameraLensDirection.front,
      )
      .toList()[config.defaultFrontCameraIndex];

  Future<void> swapFrontBack({
    bool restore = false,
  }) async {
    if (restore) {
      currDescription =
          controller?.description ?? currDescription ?? backCamera;
    } else {
      if (currDescription == null) {
        currDescription = backCamera;
      } else {
        currDescription =
            currDescription == backCamera ? frontCamera : backCamera;
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
    print('Initializing camera');
    final prevCamera = controller;
    final cameraController = CameraController(
      cameraDescription,
      config.resolutionPreset,
      enableAudio: config.enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;
    await prevCamera?.dispose();

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

  Widget exposureModeSettings(CameraController? controller) {
    final styleAuto = TextButton.styleFrom(
      foregroundColor: controller?.value.exposureMode == ExposureMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final styleLocked = TextButton.styleFrom(
      foregroundColor: controller?.value.exposureMode == ExposureMode.locked
          ? Colors.orange
          : Colors.blue,
    );
    return Column(
      children: <Widget>[
        const Center(
          child: Text('Exposure Mode'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
              style: styleAuto,
              onPressed: () =>
                  onSetExposureModeButtonPressed(ExposureMode.auto),
              onLongPress: controller == null
                  ? null
                  : () {
                      controller.setExposurePoint(null);
                      // showInSnackBar('Resetting exposure point');
                    },
              child: const Text('AUTO'),
            ),
            TextButton(
              style: styleLocked,
              onPressed: () =>
                  onSetExposureModeButtonPressed(ExposureMode.locked),
              child: const Text('LOCKED'),
            ),
            TextButton(
              style: styleLocked,
              onPressed: () {
                setExposureOffset(0);
              },
              child: const Text('RESET OFFSET'),
            ),
          ],
        ),
        const Center(
          child: Text('Exposure Offset'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(minAvailableExposureOffset.toString()),
            Slider(
              value: currentExposureOffset,
              min: minAvailableExposureOffset,
              max: maxAvailableExposureOffset,
              label: currentExposureOffset.toString(),
              onChanged:
                  minAvailableExposureOffset == maxAvailableExposureOffset
                      ? null
                      : setExposureOffset,
            ),
            Text(maxAvailableExposureOffset.toString()),
          ],
        ),
      ],
    );
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      //showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
      // ignore: unused_catch_clause
    } on CameraException catch (e) {
      //_showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }
    currentExposureOffset = offset;
    if (mounted) {
      setState(() {});
    }

    try {
      await controller!.setExposureOffset(offset);
    } /* on CameraException  */ catch (e) {
      // TODO(anandas): : handler error
      rethrow;
    }
  }

  Widget focusModeSettings(CameraController? controller) {
    final styleAuto = TextButton.styleFrom(
      foregroundColor: controller?.value.focusMode == FocusMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final styleLocked = TextButton.styleFrom(
      foregroundColor: controller?.value.focusMode == FocusMode.locked
          ? Colors.orange
          : Colors.blue,
    );
    return Column(
      children: <Widget>[
        const Center(
          child: Text('Focus Mode'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
              style: styleAuto,
              onPressed: controller != null
                  ? () => onSetFocusModeButtonPressed(FocusMode.auto)
                  : null,
              onLongPress: () {
                if (controller != null) {
                  controller.setFocusPoint(null);
                }
                //showInSnackBar('Resetting focus point');
              },
              child: const Text('AUTO'),
            ),
            TextButton(
              style: styleLocked,
              onPressed: controller != null
                  ? () => onSetFocusModeButtonPressed(FocusMode.locked)
                  : null,
              child: const Text('LOCKED'),
            ),
          ],
        ),
      ],
    );
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      //showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      //_showCameraException(e);
      rethrow;
    }
  }

  Widget cameraSelector(List<CameraDescription> cameras) {
    final backCameras = cameras
        .where(
          (e) => e.lensDirection == CameraLensDirection.back,
        )
        .toList();
    final numberOfBackCameras = backCameras.length;
    final numberOfFrontCameras = cameras
        .where(
          (e) => e.lensDirection == CameraLensDirection.front,
        )
        .length;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Back Camera:',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ToggleButtons(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.green[700],
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                isSelected: widget.cameras
                    .where(
                      (e) => e.lensDirection == CameraLensDirection.back,
                    )
                    .indexed
                    .map((e) {
                  final (index, _) = e;
                  return index == config.defaultBackCameraIndex;
                }).toList(),
                children: List<int>.generate(
                  widget.cameras
                      .where(
                        (e) => e.lensDirection == CameraLensDirection.back,
                      )
                      .length,
                  (i) => i,
                )
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          'Camera $e',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                    .toList(),
                onPressed: (index) {
                  if (index != config.defaultBackCameraIndex) {
                    config = config.copyWith(defaultBackCameraIndex: index);
                    initializeCameraController(backCamera);
                  }
                },
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Image Resolution:',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          FittedBox(
            child: ToggleButtons(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.green[700],
              selectedColor: Colors.white,
              fillColor: Colors.green[200],
              color: Colors.green[400],
              isSelected: ResolutionPreset.values.map((e) {
                return e == config.resolutionPreset;
              }).toList(),
              children: ResolutionPreset.values
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Text(
                        e.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                  .toList(),
              onPressed: (index) {
                if (index !=
                    ResolutionPreset.values.indexOf(config.resolutionPreset)) {
                  config = config.copyWith(
                    resolutionPreset: ResolutionPreset.values[index],
                  );
                  initializeCameraController(backCamera);
                }
              },
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Audio',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  config = config.copyWith(
                    enableAudio: !config.enableAudio,
                  );
                  initializeCameraController(currDescription ?? backCamera);
                },
                icon: Icon(
                  config.enableAudio
                      ? MdiIcons.volumeHigh
                      : MdiIcons.volumeMute,
                ),
              ),
              if (!config.enableAudio) const Text('(Muted)'),
            ],
          ),
        ],
      ),
    );
  }
}

class NumberDropdown extends StatefulWidget {
  const NumberDropdown({required this.n, required this.label, super.key});
  final int n;
  final String label;

  @override
  NumberDropdownState createState() => NumberDropdownState();
}

class NumberDropdownState extends State<NumberDropdown> {
  int selectedNumber = 0;

  @override
  Widget build(BuildContext context) {
    final numberList = List<int>.generate(widget.n, (i) => i);

    return DropdownMenu<int>(
      initialSelection: selectedNumber,
      label: Text(widget.label),
      // hint: const Text('Select Camera'),
      onSelected: (int? newValue) {
        if (newValue != null) {
          setState(() {
            selectedNumber = newValue;
          });
        }
      },
      expandedInsets: EdgeInsets.zero,
      dropdownMenuEntries: numberList.map<DropdownMenuEntry<int>>((int value) {
        return DropdownMenuEntry<int>(
          value: value,
          label: value.toString(),
        );
      }).toList(),
    );
  }
}
