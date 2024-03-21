import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_preview_core.dart';
import 'models/camera_state.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({
    required this.cameraState,
    this.children = const [],
    super.key,
  });
  final CameraState cameraState;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  double _currentScale = 1;
  double _baseScale = 1;

  @override
  Widget build(BuildContext context) {
    final controller = widget.cameraState.controller;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Center(
        child: Listener(
          onPointerDown: (_) => _pointers++,
          onPointerUp: (_) => _pointers--,
          child: ValueListenableBuilder<CameraValue>(
            valueListenable: controller,
            builder: (BuildContext context, Object? value, Widget? child) {
              return AspectRatioConditional(
                aspectRatio: _isLandscape()
                    ? controller.value.aspectRatio
                    : 1 / controller.value.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreviewCore(
                      cameraState: widget.cameraState,
                    ),
                    LayoutBuilder(
                      builder: (
                        BuildContext context,
                        BoxConstraints constraints,
                      ) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onScaleStart: _handleScaleStart,
                          onScaleUpdate: _handleScaleUpdate,
                          onTapDown: (TapDownDetails details) =>
                              onViewFinderTap(details, constraints),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(
      widget.cameraState.minAvailableZoom,
      widget.cameraState.maxAvailableZoom,
    );

    await widget.cameraState.controller.setZoomLevel(_currentScale);
  }

  Future<void> onViewFinderTap(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    final cameraController = widget.cameraState.controller;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    try {
      await cameraController.setExposurePoint(offset);
      await cameraController.setFocusPoint(offset);
    } catch (e) {
      /** */
      print('unable to set offset');
    }
  }

  Widget _wrapInRotatedBox({required Widget child}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  bool _isLandscape() {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ].contains(_getApplicableOrientation());
  }

  int _getQuarterTurns() {
    final turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[_getApplicableOrientation()]!;
  }

  DeviceOrientation _getApplicableOrientation() {
    return widget.cameraState.controller.value.isRecordingVideo
        ? widget.cameraState.controller.value.recordingOrientation!
        : (widget.cameraState.controller.value.previewPauseOrientation ??
            widget.cameraState.controller.value.lockedCaptureOrientation ??
            widget.cameraState.controller.value.deviceOrientation);
  }
}

class AspectRatioConditional extends StatelessWidget {
  const AspectRatioConditional({
    required this.child,
    super.key,
    this.aspectRatio,
  });
  final double? aspectRatio;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) {
    if (aspectRatio == null) return child;
    return AspectRatio(
      aspectRatio: aspectRatio!,
      child: child,
    );
  }
}
