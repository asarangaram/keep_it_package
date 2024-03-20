import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
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
      data: (cameraState) => Listener(
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
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularButton(
                          icon: Icons.camera_alt,
                          size: 36,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CLButtonText.large(
                          cameraState.cameraSettings.resolutionPreset.name,
                          color: Colors.white.withAlpha(192),
                          onTap: ref
                              .read(cameraControllerProvider.notifier)
                              .nextResolution,
                        ),
                      ),
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

class CircularButton extends StatelessWidget {
  const CircularButton({
    required this.icon,
    this.size = 34,
    this.onPressed,
    this.hasDecoration = true,
    this.isOpaque = false,
    super.key,
  });
  final VoidCallback? onPressed;
  final double size;
  final IconData icon;
  final bool hasDecoration;
  final bool isOpaque;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.all(hasDecoration ? 4 : 0),
        child: Container(
          decoration: hasDecoration
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOpaque
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context).colorScheme.background.withAlpha(128),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                )
              : null,
          padding: EdgeInsets.all(hasDecoration ? 16 : 8),
          child: Icon(
            icon,
            size: size,
            color: hasDecoration
                ? Theme.of(context).colorScheme.onBackground
                : Theme.of(context).colorScheme.background,
          ),
        ),
      ),
    );
  }
}
