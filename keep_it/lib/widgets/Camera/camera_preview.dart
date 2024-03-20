import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/Camera/get_cameras.dart';

import 'providers/camera_state.dart';

class CameraPreviewWithZoom extends ConsumerStatefulWidget {
  const CameraPreviewWithZoom({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CameraPreviewWithScale();
}

class _CameraPreviewWithScale extends ConsumerState<CameraPreviewWithZoom> {
  double _baseScale = 1;
  int _pointers = 0;

  @override
  Widget build(BuildContext context) {
    final cameraStateAsync = ref.watch(cameraControllerProvider);
    return cameraStateAsync.when(
      error: (e, st) => CameraError(errorMessage: e.toString()),
      loading: CameraLoading.new,
      data: (cameraState) => Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: cameraState.cameraController.value.isRecordingVideo
                ? Colors.redAccent
                : Colors.grey,
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Center(
            child: Listener(
              onPointerDown: (_) => _pointers++,
              onPointerUp: (_) => _pointers--,
              child: CameraPreview(
                cameraState.cameraController,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: (_) =>
                          _baseScale = cameraState.cameraSettings.zoomLevel0,
                      onScaleUpdate: _handleScaleUpdate,
                      onTapDown: (TapDownDetails details) => onViewFinderTap(
                        cameraState.cameraController,
                        details,
                        constraints,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }
    print(_baseScale * details.scale);
    ref.read(cameraControllerProvider.notifier).zoomLevel =
        _baseScale * details.scale;
  }

  Future<void> onViewFinderTap(
    CameraController cameraController,
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    try {
      await cameraController.setExposurePoint(offset);
      await cameraController.setFocusPoint(offset);
    } catch (e) {
      /* */
    }
  }
}
