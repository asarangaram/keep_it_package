// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: lines_longer_than_80_chars

import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'Camera/camera_preview.dart';
import 'Camera/camera_preview_core.dart';
import 'Camera/models/camera_state.dart';
import 'camera_screen.dart';

mixin CameraControl<T extends StatefulWidget> on State<T> {
  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onAppLifecycleStateChange({
    required AppLifecycleState appState,
    required CameraDescription description,
    required CameraState? cameraState,
    required void Function(CameraState? cameraState) updateCameraState,
    required void Function(String) onCameraError,
  }) {
    if (appState == AppLifecycleState.inactive) {
      cameraState?.dispose();
      updateCameraState(null);
    } else if (appState == AppLifecycleState.resumed) {
      if (cameraState == null) {
        CameraState.createAsync(
          description,
          onCameraStateReady: updateCameraState,
          onCameraError: onCameraError,
        );
      } else {
        // Does this required?
        cameraState.controller
            .setDescription(cameraState.controller.description);
      }
    }
  }
}

class CameraView extends StatelessWidget {
  const CameraView({
    required this.cameras,
    required this.onError,
    required this.onLoading,
    super.key,
  });
  final List<CameraDescription> cameras;
  final Widget Function(String) onError;
  final Widget Function() onLoading;

  @override
  Widget build(BuildContext context) {
    try {
      if (cameras.isEmpty) {
        throw Exception('No camera found.');
      }
      return FullscreenLayout(
        useSafeArea: false,
        child: _CameraView(
          cameras: cameras,
          onError: onError,
          onLoading: onLoading,
        ),
      );
    } catch (e) {
      return onError(e.toString());
    }
  }
}

/// Camera example home widget.
class _CameraView extends StatefulWidget {
  /// Default Constructor
  const _CameraView({
    required this.cameras,
    required this.onError,
    required this.onLoading,
    // ignore: unused_element
    this.defaultCameraIndex = 0,
  });
  final List<CameraDescription> cameras;
  final int defaultCameraIndex;
  final Widget Function(String) onError;
  final Widget Function() onLoading;

  @override
  State<_CameraView> createState() {
    return _CameraViewState();
  }
}

class _CameraViewState extends State<_CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin, CameraControl {
  CameraState? cameraState;
  String? errorString;

  late AnimationController bottomMenuAnimationController;
  late Animation<double> bottomMenuAnimation;

  bool isFullScreen = true;
  bool isVideoMode = false;
  /* void refresh() {
    if (mounted) {
      setState(() {});
    }
  } */
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

    bottomMenuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    bottomMenuAnimation = CurvedAnimation(
      parent: bottomMenuAnimationController,
      curve: Curves.easeInCubic,
    );
    CameraState.createAsync(
      widget.cameras[widget.defaultCameraIndex],
      onCameraStateReady: onCameraStateChanged,
      onCameraError: onError,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    bottomMenuAnimationController.dispose();
    cameraState?.dispose();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    onAppLifecycleStateChange(
      appState: appState,
      description: cameraState?.controller.description ??
          widget.cameras[widget.defaultCameraIndex],
      cameraState: cameraState,
      updateCameraState: onCameraStateChanged,
      onCameraError: onError,
    );
  }

  // #enddocregion AppLifecycle
  bool get showControl =>
      !isFullScreen && !cameraState!.controller.value.isRecordingVideo;

  @override
  Widget build(BuildContext context) {
    if (cameraState == null) {
      return widget.onLoading();
    }
    final controller = cameraState!.controller;
    final cameraState0 = cameraState!;

    if (!showControl) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }

    return DecoratedBox(
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.onBackground),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreviewCore(
            controller: cameraState0.controller,
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color:
                    Colors.black.withOpacity(0.5), // Adjust opacity as needed
              ),
            ),
          ),
          CameraPreviewWidget(
            isFullScreen: !showControl,
            controller: controller,
            minAvailableZoom: cameraState0.minAvailableZoom,
            maxAvailableZoom: cameraState0.maxAvailableZoom,
          ),
          /* SafeArea(
            child: Column(
              children: [
                CameraTopMenu(
                  controller: controller,
                  cameras: widget.cameras,
                  showMenu: showControl,
                  onToggleFullScreen: () {
                    setState(() {
                      isFullScreen = !isFullScreen;
                    });
                  },
                ),
                Expanded(
                  child: CameraPreviewWidget(
                    isFullScreen: !showControl,
                    controller: controller,
                    minAvailableZoom: cameraState0.minAvailableZoom,
                    maxAvailableZoom: cameraState0.maxAvailableZoom,
                  ),
                ),
                if (isVideoMode)
                  VideoControl(controller: controller)
                else
                  TakePhotoControl(controller: controller),
                //_modeControlRowWidget(),
              ],
            ),
          ), */
        ],
      ),
    );
  }

  /// Display a bar with buttons to change the flash and exposure modes
  Widget _modeControlRowWidget() {
    if (cameraState == null) {
      return Container();
    }
    final controller = cameraState!.controller;
    return Container(
      //   decoration: const BoxDecoration(color: Colors.blue),
      child: Column(
        children: <Widget>[
          Align(
            alignment: showControl ? Alignment.centerRight : Alignment.center,
            child: CircularButton(
              onPressed: () {},
              icon: showControl ? Icons.close : MdiIcons.menuUp,
              size: 44,
              hasDecoration: false,
            ),
          ),
          if (showControl) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CLButtonIconLabelled.verySmall(
                  MdiIcons.camera,
                  'Camera Mode\n${isVideoMode ? "Video" : "Photo"}',
                  onTap: () {
                    setState(() {
                      isVideoMode = !isVideoMode;
                    });
                  },
                  color: Theme.of(context).colorScheme.background,
                ),
                CLButtonIconLabelled.verySmall(
                  Icons.filter_center_focus,
                  switch (controller.value.exposureMode) {
                    ExposureMode.auto => 'Exposure Mode\nAuto',
                    ExposureMode.locked => 'Exposure Mode\nLocked',
                  },
                  onTap: () {
                    controller.setExposureMode(
                      ExposureMode.values.next(controller.value.exposureMode),
                    );
                  },
                  color: controller.value.exposureMode == ExposureMode.auto
                      ? Colors.orange
                      : Colors.blue,
                ),
                CLButtonIconLabelled.verySmall(
                  Icons.filter_center_focus,
                  switch (controller.value.focusMode) {
                    FocusMode.auto => 'Focus Mode\nAuto',
                    FocusMode.locked => 'Focus Mode\nLocked',
                  },
                  onTap: () {
                    controller.setFocusMode(
                      FocusMode.values.next(controller.value.focusMode),
                    );
                  },
                  color: controller.value.focusMode == FocusMode.auto
                      ? Colors.orange
                      : Colors.blue,
                ),
              ],
            ),
            const Divider(
              indent: 16,
              endIndent: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CLText.verySmall(
                  'Exposure\nOffset:',
                  color: Theme.of(context).colorScheme.background,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CLText.small(
                      cameraState!.minAvailableExposureOffset.toString(),
                      color: Theme.of(context).colorScheme.background,
                    ),
                    Slider(
                      value: cameraState!.currentExposureOffset,
                      min: cameraState!.minAvailableExposureOffset,
                      max: cameraState!.maxAvailableExposureOffset,
                      label: cameraState!.currentExposureOffset.toString(),
                      onChanged: cameraState!.minAvailableExposureOffset ==
                              cameraState!.maxAvailableExposureOffset
                          ? null
                          : (value) {
                              cameraState?.setExposureOffset(
                                value,
                                updateCameraState: onCameraStateChanged,
                                onCameraError: onError,
                              );
                            },
                    ),
                    CLText.small(
                      cameraState!.maxAvailableExposureOffset.toString(),
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
