import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'Camera/camera_preview.dart';
import 'Camera/preview.dart';

class CameraInterface extends StatefulWidget {
  const CameraInterface({
    required this.cameraController,
    this.onCapturePressed,
    this.onSwitchCameraPressed,
    this.onFlashModePressed,
    this.onVideoCapturePressed,
    this.onToggleAudioPressed,
    super.key,
  });
  final CameraController cameraController;

  final VoidCallback? onCapturePressed;
  final VoidCallback? onSwitchCameraPressed;
  final VoidCallback? onFlashModePressed;
  final VoidCallback? onVideoCapturePressed;
  final VoidCallback? onToggleAudioPressed;

  @override
  State<CameraInterface> createState() => _CameraInterfaceState();
}

class _CameraInterfaceState extends State<CameraInterface> {
  bool useAspectRatio = false;
  @override
  Widget build(BuildContext context) {
    final previewWidget = CameraPreview2(
      widget.cameraController,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              CircularButton(
                onPressed: () {
                  setState(() {
                    useAspectRatio = !useAspectRatio;
                  });
                },
                icon: useAspectRatio
                    ? MdiIcons.arrowExpandVertical
                    : MdiIcons.arrowCollapseVertical,
                size: 24,
                hasDecoration: false,
              ),
              CircularButton(
                onPressed: widget.onFlashModePressed,
                icon: Icons.flash_on,
                size: 24,
                hasDecoration: false,
              ),
              CircularButton(
                onPressed: widget.onSwitchCameraPressed,
                icon: Icons.switch_camera,
                size: 24,
                hasDecoration: false,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Container(),
              ),
              CircularButton(
                onPressed: widget.onCapturePressed,
                icon: MdiIcons.camera,
                size: 44,
              ),
              Flexible(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: CircularButton(
                      onPressed: widget.onCapturePressed,
                      icon: MdiIcons.video,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return SafeArea(
      top: !useAspectRatio,
      bottom: !useAspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: useAspectRatio
                ? AspectRatio(
                    aspectRatio: widget.cameraController.value
                        .aspectRatio, // Example aspect ratio (adjust as needed)
                    child: previewWidget,
                  )
                : previewWidget,
          );
        },
      ),
    );
  }
}
/*
if (useAspectRatio)
                ,
 */