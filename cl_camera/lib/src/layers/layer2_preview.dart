import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CamearPreviewLayer extends StatelessWidget {
  const CamearPreviewLayer({required this.controller, super.key});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return Container();
    /* return AspectRatio(
      aspectRatio: 1 / controller.value.aspectRatio,
      child: Stack(
        children: [
          CameraPreview(
            controller,
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
              controller.setZoomLevel(scale).then((value) {
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
        ],
      ),
    ); */
  }
}
