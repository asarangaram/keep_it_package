import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewLayer extends StatefulWidget {
  const CameraPreviewLayer({
    required this.controller,
    required this.currentZoomLevel,
    required this.onChangeZoomLevel,
    required this.aspectRatio,
    super.key,
  });
  final CameraController controller;
  final double currentZoomLevel;
  final void Function(double) onChangeZoomLevel;
  final double aspectRatio;

  @override
  State<CameraPreviewLayer> createState() => _CameraPreviewLayerState();
}

class _CameraPreviewLayerState extends State<CameraPreviewLayer> {
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  final double _minAvailableZoom = 1;
  final double _maxAvailableZoom = 1;
  double _currentScale = 1;
  double _baseScale = 1;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: CameraPreview(
        widget.controller,
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

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await widget.controller.setZoomLevel(_currentScale);
    widget.onChangeZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final cameraController = widget.controller;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController
      ..setExposurePoint(offset)
      ..setFocusPoint(offset);
  }
}
