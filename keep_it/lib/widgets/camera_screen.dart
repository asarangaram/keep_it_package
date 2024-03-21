import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

class CircularButton extends StatelessWidget {
  const CircularButton({
    required this.icon,
    super.key,
    this.size = 34,
    this.onPressed,
    this.hasDecoration = true,
    this.isOpaque = false,
    this.foregroundColor,
    this.backgroundColor,
  });
  final VoidCallback? onPressed;
  final double size;
  final IconData icon;
  final bool hasDecoration;
  final bool isOpaque;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.all(hasDecoration ? 8 : 4),
        child: Container(
          decoration: hasDecoration
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOpaque
                      ? backgroundColor ??
                          Theme.of(context).colorScheme.background
                      : (backgroundColor ??
                              Theme.of(context).colorScheme.background)
                          .withAlpha(128),
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
          height: hasDecoration ? size + 8 : null,
          width: hasDecoration ? size + 8 : null,
          //  padding: EdgeInsets.all(hasDecoration ? 8 : 4),
          child: Icon(
            icon,
            size: size,
            color: foregroundColor ??
                (hasDecoration
                    ? Theme.of(context).colorScheme.onBackground
                    : Theme.of(context).colorScheme.background),
          ),
        ),
      ),
    );
  }
}

extension EXTNextOnList<T> on List<T> {
  T next(T item) => this[(indexOf(item) + 1) % length];
}

class CameraTopMenu extends StatelessWidget {
  const CameraTopMenu({
    required this.cameras,
    required this.controller,
    required this.showMenu,
    required this.onToggleFullScreen,
    super.key,
  });
  final CameraController controller;
  final List<CameraDescription> cameras;
  final bool showMenu;
  final void Function() onToggleFullScreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showMenu)
            CircularButton(
              onPressed: onCaptureOrientationLockButtonPressed,
              icon: controller.value.isCaptureOrientationLocked
                  ? Icons.screen_lock_rotation
                  : Icons.screen_rotation,
              size: 24,
              hasDecoration: false,
            ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showMenu) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  CircularButton(
                    onPressed: () {
                      controller.setFlashMode(
                        FlashMode.values.next(controller.value.flashMode),
                      );
                    },
                    size: 24,
                    hasDecoration: false,
                    icon: switch (controller.value.flashMode) {
                      FlashMode.off => Icons.flash_off,
                      FlashMode.auto => Icons.flash_auto,
                      FlashMode.always => Icons.flash_on,
                      FlashMode.torch => Icons.highlight,
                    },
                  ),
                ],
                if (showMenu) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  CircularButton(
                    onPressed: () {
                      controller
                          .setDescription(cameras.next(controller.description));
                    },
                    icon: Icons.switch_camera,
                    size: 24,
                    hasDecoration: false,
                  ),
                ],
                ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  CircularButton(
                    onPressed: onToggleFullScreen,
                    icon: showMenu ? MdiIcons.eyeOff : MdiIcons.eye,
                    size: 24,
                    foregroundColor: showMenu ? null : Colors.yellow,
                    hasDecoration: false,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      final cameraController = controller;
      if (cameraController.value.isCaptureOrientationLocked) {
        await cameraController.unlockCaptureOrientation();
      } else {
        await cameraController.lockCaptureOrientation();
      }
    } on CameraException catch (e) {
      /** */
    }
  }
}

class TakePhotoControl extends StatelessWidget {
  const TakePhotoControl({
    required this.controller,
    super.key,
  });
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularButton(
        onPressed: () async {
          if (!controller.value.isTakingPicture) {
            final xFile = await controller.takePicture();
          }
        },
        icon: MdiIcons.camera,
        size: 44,
      ),
    );
  }
}

class VideoControl extends StatefulWidget {
  const VideoControl({
    required this.controller,
    super.key,
  });
  final CameraController controller;

  @override
  State<VideoControl> createState() => _VideoControlState();
}

class _VideoControlState extends State<VideoControl> {
  bool waiting = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(),
        ),
        CircularButton(
          onPressed: () async {
            setState(() {
              waiting = true;
            });
            if (!widget.controller.value.isRecordingVideo) {
              await widget.controller.startVideoRecording();
            } else if (widget.controller.value.isRecordingPaused) {
              await widget.controller.resumeVideoRecording();
            } else {
              await widget.controller.pauseVideoRecording();
            }
            setState(() {
              waiting = false;
            });
          },
          icon: widget.controller.value.isRecordingVideo
              ? widget.controller.value.isRecordingPaused
                  ? MdiIcons.circle
                  : MdiIcons.pause
              : MdiIcons.video,
          size: 44,
          backgroundColor: widget.controller.value.isRecordingVideo &&
                  !widget.controller.value.isRecordingPaused
              ? Theme.of(context).colorScheme.error
              : null,
          foregroundColor: widget.controller.value.isRecordingVideo
              ? Theme.of(context).colorScheme.onError
              : null,
        ),
        if (widget.controller.value.isRecordingVideo && !waiting)
          Flexible(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: CircularButton(
                  onPressed: () async {
                    await widget.controller.stopVideoRecording();
                  },
                  icon: MdiIcons.stop,
                  size: 32,
                ),
              ),
            ),
          )
        else
          Flexible(child: Container()),
      ],
    );
  }
}
