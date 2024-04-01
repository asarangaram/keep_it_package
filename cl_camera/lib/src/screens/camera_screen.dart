// ignore_for_file:  lines_longer_than_80_chars, avoid_print

import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:permission_handler/permission_handler.dart';

import '../extensions.dart';
import '../layers/layer1_background.dart';
import '../layers/layer2_preview.dart';
import '../widgets/permission.dart';

class CameraState {
  CameraState({
    required this.resolutionPreset,
    required this.minAvailableExposureOffset,
    required this.maxAvailableExposureOffset,
    required this.minAvailableZoom,
    required this.maxAvailableZoom,
    this.currDescription,
    this.currentZoomLevel = 1,
    this.currentExposureOffset = 0,
  });

  final double currentZoomLevel;
  final double currentExposureOffset;
  final double minAvailableExposureOffset;
  final double maxAvailableExposureOffset;
  final double minAvailableZoom;
  final double maxAvailableZoom;
  ResolutionPreset resolutionPreset;
  CameraDescription? currDescription;
}

class CameraScreen extends StatefulWidget {
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
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;

  CameraState? cameraState;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

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
      return RequestPermission(
        getPermissionStatus: getPermissionStatus,
      );
    }
    if (!_isCameraInitialized) {
      return const CLLoadingView();
    }
    return Stack(
      children: [
        CameraBackgroundLayer(controller: controller!),
        /*  CamearPreviewLayer(
          controller: controller!,
        ), */
      ],
    );
  }

  Future<void> getPermissionStatus() async {
    await Permission.camera.request();
    final status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      await onNewCameraSelected();
      // Set and initialize the new camera
    } else {
      log('Camera Permission: DENIED');
    }
  }

  Future<void> onNewCameraSelected({
    bool restore = false,
  }) async {
    await getCamera(
      cameras: widget.cameras,
      restore: restore,
      resolutionPreset:
          cameraState?.resolutionPreset ?? widget.currentResolutionPreset,
      controllerListener: () {
        if (mounted) setState(() {});
      },
      onSuccess: ({required controller, required state}) {
        if (mounted) {
          setState(() {
            this.controller = controller;
            cameraState = state;
            _isCameraInitialized = controller.value.isInitialized;
          });
        }
      },
    );
  }

  static Future<void> getCamera({
    required List<CameraDescription> cameras,
    required ResolutionPreset resolutionPreset,
    required void Function({
      required CameraController controller,
      required CameraState state,
    }) onSuccess,
    required VoidCallback controllerListener,
    required bool restore,
    CameraController? controller,
    CameraDescription? description,
  }) async {
    var currDescription = description;
    final currentResolutionPreset = resolutionPreset;
    var minAvailableExposureOffset = 0.0;
    var maxAvailableExposureOffset = 0.0;
    var minAvailableZoom = 1.0;
    var maxAvailableZoom = 1.0;

    if (restore) {
      currDescription =
          controller?.description ?? currDescription ?? cameras[0];
    } else {
      if (currDescription == null) {
        currDescription = cameras[0];
      } else {
        currDescription = cameras.next(currDescription);
      }
    }
    final previousCameraController = controller;

    final cameraController = CameraController(
      currDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    // Update UI if controller updated
    cameraController.addListener(controllerListener);

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => minAvailableZoom = value),
      ]);
      onSuccess(
        controller: cameraController,
        state: CameraState(
          resolutionPreset: resolutionPreset,
          currDescription: description,
          minAvailableExposureOffset: minAvailableExposureOffset,
          maxAvailableExposureOffset: maxAvailableExposureOffset,
          minAvailableZoom: minAvailableZoom,
          maxAvailableZoom: maxAvailableZoom,
        ),
      );
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
  }
}
